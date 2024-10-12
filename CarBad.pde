class CarBad extends Box{
  
  float vel;
  //float acc;
  float max_vel = 5;
  float inv_max_vel = 1 / max_vel;
  
  float acc;
  PVector half_size;
  PVector dir;
  
  float engine_max = .25;
  float engine_fraction = 0;
  boolean pedal_down = false;
  
  float brake_max = .1;
  boolean brake_down = false;
  
  int turning = 0; // -1 = left, 1 = right, 0 = none
  int last_turning = turning;
  
  float turn_rate = .05;
  float wheel_turn_angle = 0;
  float wheel_turn_max = .05;
  
  boolean finished = false;
  
  boolean equal_dist_angle_rays = false;
  
  PVector[] rays = new PVector[1 + 16];
  PVector[] ray_endpoints = new PVector[rays.length];
  float[] ray_dists = new float[rays.length];
  float[] ray_dists_norm = new float[rays.length]; // normalized to be between 0 and 1
  
  float max_dist = carsdriving2.max_dist;//sqrt(map_width * map_width + map_height * map_height);
  float inv_max_dist = carsdriving2.inv_max_dist;//1 / max_dist;
  float fitness;
  float fitness_not_norm;
  float[] fitness_w_index; // array with fitness and index
  int num_dir_changes = 0; // number of times the steering changes direction
  
  float dist_travelled = 0;
  float distsq_to_goal = MAX_FLOAT;
  
  NeuralNetwork2 nn2;
  float[] controls;
  
  int control_box_pos = 0;
  boolean show_rays = false;
  
  int alpha = 15;
  
  color c0 = color(255);
  color c = c0;
  
  CarBad(float x, float y, float size_x, float size_y, float angle){
    super(x, y, size_x, size_y, angle);
    this.vel = 0;
    this.acc = 0;
    this.half_size = this.size.copy().mult(.5);
    this.r_matrix = new PVector[]{new PVector(cos(angle), -sin(angle)), new PVector(sin(angle), cos(angle))};
    this.r_matrix_T = transpose(r_matrix);
    for(int i = 0; i < rays.length; i++){
      this.ray_endpoints[i] = new PVector(max_dist, max_dist);
    }
    int inodes = (world == 2) ? rays.length + 1: rays.length + 1 + 2; // world 4 has extra for distance
    this.nn2 = new NeuralNetwork2(inodes, new int[]{16, 16}, 6, .1); // +1 is for vel
    this.controls = new float[nn2.Onodes];
    updateCarInfo();
  }
  
  CarBad(float x, float y, float size_x, float size_y, float angle, NeuralNetwork2 nn2){
    super(x, y, size_x, size_y, angle);
    this.vel = 0;
    this.acc = 0;
    this.half_size = this.size.copy().mult(.5);
    this.r_matrix = new PVector[]{new PVector(cos(angle), -sin(angle)), new PVector(sin(angle), cos(angle))};
    this.r_matrix_T = transpose(r_matrix);
    for(int i = 0; i < rays.length; i++){
      this.ray_endpoints[i] = new PVector(max_dist, max_dist);
    }
    this.nn2 = nn2;
    this.controls = new float[nn2.Onodes];
    updateCarInfo();
  }
  
  void updateCarInfo(){
    updateCarDirs();
    calcCornersCar();
  }
  
  void updateCarDirs(){
    findDir();
    findRayDirs();
  }
  
  void update(){
    checkFinished();
    
    controls = nn2Controls(); // this lets the nn set the engine/brake/steering
    if(turning != last_turning){
      num_dir_changes++;
    }
    
    
    acc = engine_max * engine_fraction;
    float friction = .007;
    acc -= vel * .005;
    
    if(!pedal_down){
      acc -= friction;
      acc = constrain(acc, -abs(vel), 0);
    }
    if(brake_down){
      acc -= brake_max;
      acc = constrain(acc, -abs(vel), 0);
    }
    //vel.add(dir.copy().mult(acc));
    vel += acc;
    vel = constrain(vel, 0, max_vel);
    pos.add(dir.copy().mult(vel));
    //wheel_turn_angle = constrain(wheel_turn_angle + turning * turn_rate, -wheel_turn_max, wheel_turn_max);
    if(abs(vel) > 0){
      addAngle(turn_rate * turning * calcTurnFraction(vel));
    }
    last_turning = turning;
    calcCornersCar(); // we don't want to update the angles if we don't have to
    //updateCarInfo(); // so we only do the corners unless we rotate
    dist_travelled += vel * .1; // * .1 to keep it from getting too large in the fitness calculation
    distsq_to_goal = pos.copy().sub(goal_pos).magSq();
  }
  
  float calcTurnFraction(float v){
    return (v * .5 / (max_vel * sq(max_vel))) * sq(3 * max_vel - 2 * v);
  }
  
  float[] nn2Controls(){
    float[] inputs;
    if(world == 2){
      inputs = concat(ray_dists_norm, new float[]{vel * inv_max_vel});
    } else {
      PVector goal_dist = goal_pos.copy().sub(pos).mult(inv_max_dist);
      inputs = concat(concat(ray_dists_norm, new float[]{vel * inv_max_vel}), subset(goal_dist.array(), 0, 2));
    }
    float[] _controls = toArray(nn2.check(toMatrix(inputs)));
    if(nn2.Onodes == 2){
      //controls[0] is the acc/brake, controls[1] is steering
      if(_controls[0] < .45){
        setEngineFrac(0);
        pedal_down = false;
        brake_down = true;
      } else if(_controls[0] >= .45 && _controls[0] < .55){
        setEngineFrac(0);
        pedal_down = false;
        brake_down = false;
      } else if(_controls[0] >= .55){
        setEngineFrac(1);
        pedal_down = true;
        brake_down = false;
      }
      
      if(_controls[1] < .45){
        turning = -1;
      } else if(_controls[1] >= .45 && _controls[1] < .55){
        turning = 0;
      } else if(_controls[1] >= .55){
        turning = 1;
      }
      
    } else if(nn2.Onodes == 6){
      float[] drive_controls = subset(_controls, 0, 3);
      float[] dir_controls = subset(_controls, 3);
      float drivemax = max(drive_controls);
      float dirmax = max(dir_controls); 
      if(drive_controls[0] == drivemax){
        setEngineFrac(0);
        pedal_down = false;
        brake_down = true;
      } else if(drive_controls[1] == drivemax){
        setEngineFrac(0);
        pedal_down = false;
        brake_down = false;
      } else if(drive_controls[2] == drivemax){
        setEngineFrac(1);
        pedal_down = true;
        brake_down = false;
      }
      
      if(dir_controls[0] == dirmax){
        turning = -1;
      } else if(dir_controls[1] == dirmax){
        turning = 0;
      } else if(dir_controls[2] == dirmax){
        turning = 1;
      }
    }
    return _controls;
  }
  
  void calcCornersCar(){
    if(angle == 0){
      this.corners[0] = new PVector(pos.x, pos.y);
      this.corners[1] = new PVector(pos.x + size.x, pos.y);
      this.corners[2] = new PVector(pos.x, pos.y + size.y);
      this.corners[3] = new PVector(pos.x + size.x, pos.y + size.y);
    } else {
      this.corners[0] = vecMatMult2D(r_matrix_T, new PVector(-half_size.x, -half_size.y)).add(pos).copy().add(half_size);
      this.corners[1] = vecMatMult2D(r_matrix_T, new PVector(half_size.x, -half_size.y)).add(pos).copy().add(half_size);
      this.corners[2] = vecMatMult2D(r_matrix_T, new PVector(-half_size.x, half_size.y)).add(pos).copy().add(half_size);
      this.corners[3] = vecMatMult2D(r_matrix_T, new PVector(half_size.x, half_size.y)).add(pos).copy().add(half_size);
    }
  }
  
  void findDir(){
    this.dir = r_matrix_T[1].copy().mult(-1);
  }
  
  void findRayDirs(){
    
    rays[0] = dir;
    if(equal_dist_angle_rays){
      if(rays.length != 1){
        float ray_angle_diff = radians(180 / (rays.length - 1));
        PVector[] ray_r_matrix = new PVector[]{new PVector(cos(ray_angle_diff), -sin(ray_angle_diff)), new PVector(sin(ray_angle_diff), cos(ray_angle_diff))};
        PVector[] ray_r_matrix_T = transpose(ray_r_matrix);
        
        for(int i = 1; i < 1 + (rays.length - 1) / 2; i++){
          rays[2 * i] = vecMatMult2D(matPower2D(ray_r_matrix, i), dir);
          rays[2 * i - 1] = vecMatMult2D(matPower2D(ray_r_matrix_T, i), dir);
        }
      }
    } else {
      if(rays.length != 1){
        //println(angle);
        int a = 20;
        float max_angle_func = angle_func((rays.length - 1) / 2, a);
        float inv_max_angle_func = 1/ max_angle_func;
        for(int i = 0; i < rays.length; i++){
          rays[i] = PVector.fromAngle(angle + angle_func(i - (rays.length - 1) / 2, a) * inv_max_angle_func * HALF_PI - HALF_PI);
        }
      }
    }
      
  }
  
  float angle_func(int x, int a){
    return x * x * x + a * x;
  }
  
  void checkCollided(ArrayList<Box> boxes){
    for(Box b : boxes){
      if(b.collidable){
        float dist_sq = pos.copy().sub(b.center).magSq();
        if(dist_sq <= b.max_extent_from_center_sq){
          if(checkBoxCollision(this, b)){
            collided = true;
          } else if (b.checkBoxCollision(b, this)){
            collided = true;
          }
        }
      }
    }
  }
  
  void checkFinished(){
    if(pos.x >= map_width - 10){
      finished = true;
    }
  }
  
  void findNearestHits(ArrayList<Box> boxes){
    for(int i = 0; i < rays.length; i++){
      //int lowest_index;
      int lowest_index = MAX_INT;
      float min = max_dist;
      FloatList all_dists = new FloatList();
      for(Box b : boxes){
        float d = checkRayHit(rays[i], b);
        all_dists.append(d);
        if(d < min){
          min = d;
          lowest_index = boxes.indexOf(b);
        } //<>//
      }
      if(lowest_index == MAX_INT){
        ray_dists[i] = max_dist;
      } else {
        ray_dists[i] = all_dists.get(lowest_index);
      }
      ray_dists_norm[i] = min(ray_dists[i], 500) * .002; //ray_dists[i] * inv_max_dist;
      //println(test_index);
      //println(min);
      //println(all_dists);
      //all_dists.sort();
      //lowest_index = Arrays.binarySearch(all_dists.array(), min);
      //ray_dists[i] = all_dists.get(lowest_index);
    }
  }
  
  float checkRayHit(PVector ray_dir, Box box){
    PVector origin = pos.copy().add(half_size);
    
    float tmin = 0;
    float tmax = MAX_FLOAT;
    PVector delta = box.pos.copy().sub(origin);
    
    PVector xaxis = box.r_matrix_T[0];
    PVector yaxis = box.r_matrix_T[1];
    float ey = PVector.dot(delta, yaxis);
    float ex = PVector.dot(delta, xaxis);
    float fy = PVector.dot(ray_dir, yaxis);
    float fx = PVector.dot(ray_dir, xaxis);
    float gy = 1 / fy;
    float gx = 1 / fx;
    
    float t1 = (ex) * gx;
    float t2 = (ex + box.size.x) * gx;
    
    if(t1 > t2){
      float w = t1;
      t1 = t2;
      t2 = w;
    }
    if(t2 < tmax){
      tmax = t2;
    }
    if(t1 > tmin){
      tmin = t1;
    }
    
    t1 = (ey) * gy; // doing the ys now
    t2 = (ey + box.size.y) * gy;
    if(t1 > t2){
      float w = t1;
      t1 = t2;
      t2 = w;
    }
    if(t2 < tmax){
      tmax = t2;
    }
    if(t1 > tmin){
      tmin = t1;
    }
    
    //stroke(0);
    //strokeWeight(2);
    //fill(color(0, 255, 0));
    //float xmin = origin.x + ray_dir.x * tmin;
    //float xmax = origin.x + ray_dir.x * tmax;
    //line(xmin, 0, xmin, height);
    //line(xmax, 0, xmax, height);
    //float ymin = origin.y + ray_dir.y * tmin;
    //float ymax = origin.y + ray_dir.y * tmax;
    //line(0, ymin, width, ymin);
    //line(0, ymax, width, ymax);    
    
    if(tmax < tmin){
      //fill(color(255, 0, 0));
      //ellipse(xmin, ymin, 10, 10);
      return max_dist;
    }
    //ellipse(xmin, ymin, 10, 10);
    //fill(0);
    //ellipse(xmax, ymax, 10, 10);
    return tmin;
  }
  
  void setEngineFrac(float f){
    engine_fraction = constrain(f, 0, 1);
  }
  
  void addEngineFrac(float f){
    engine_fraction = constrain(engine_fraction + f, 0, 1);
  }
  
  void setAngle(float a){
    angle = a;
    r_matrix = new PVector[]{new PVector(cos(a), -sin(a)), new PVector(sin(a), cos(a))};
    this.r_matrix_T = transpose(r_matrix);
    updateCarInfo();
  }
  
  void addAngle(float a){
    angle += a;
    r_matrix = new PVector[]{new PVector(cos(angle), -sin(angle)), new PVector(sin(angle), cos(angle))};
    this.r_matrix_T = transpose(r_matrix);
    updateCarInfo();
  }
  
  void mutateNN(float ma, float mc){ // ma = mutate amt, mc = mutation chance per weight/bias
    nn2.mutate(ma, mc);
  }
  
  void crossover(CarBad parent){
    nn2.crossover(parent.nn2);
  }
  
  NeuralNetwork2 copyNN(){
    return nn2.copyNN();
  }
  
  void show(){
    resetMatrix();
    if(collided){
      fill(color(255, 50, 50), alpha * 3);
    } else if(finished){
      fill(color(0, 255, 0), alpha);
    } else {
      fill(c, alpha);
    }
    
    noStroke();
    translate(pos.x + half_size.x, pos.y + half_size.y);
    rotate(angle);
    rect(-half_size.x, -half_size.y, size.x, size.y);
    //noFill();
    //stroke(0, alpha);
    //strokeWeight(1);
    //triangle(-half_size.x, half_size.y, half_size.x, half_size.y, 0, -half_size.y);
    resetMatrix();
    //stroke(color(0, 255, 0));
    //strokeWeight(5);
    //for(int i = 0; i < 4; i++){
    //  point(corners[i].x, corners[i].y);
    //}
    if(show_rays){
      strokeWeight(2);
      stroke(color(255, 0, 255));
      translate(pos.x + half_size.x, pos.y + half_size.y);
      for(int i = 0; i < rays.length; i++){
        line(0, 0, rays[i].x * ray_dists[i], rays[i].y * ray_dists[i]);
      }
    }
    if(control_box_pos != 0){
      textSize(11.75);
      stroke(0);
      fill(255);
      if(control_box_pos == 1){
        translate(0, 1.5 * size.y);
        rect(-60, -20, 120, 30);
        fill(0);
        text("controls[0]: " + str(truncate(controls[0], 5)), -59, -9);
        text("controls[1]: " + str(truncate(controls[1], 5)), -59, 6);
      } else if(control_box_pos == 2){
        resetMatrix();
        translate(15, map_height - 45);
        rect(0, 0, 120, 30);
        fill(0);
        text("controls[0]: " + str(truncate(controls[0], 5)), 1, -9 + 21);
        text("controls[1]: " + str(truncate(controls[1], 5)), 1, 6 + 21);
      }
    }
  }
}
