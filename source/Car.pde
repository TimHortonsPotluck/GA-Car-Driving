class Car extends Box{
  
  PVector vel;
  PVector acc;
  PVector dir;
  
  float engine_max = .25;
  float engine_fraction = 0;
  boolean pedal_down = false;
  
  float brake_max = .1;
  boolean brake_down = false;
  
  
  float turning = 0; // -1 = left, 1 = right, 0 = none
  float wheel_turn_max = .8;
  PVector world_wheel_dir;
  float wheel_turn_angle = 0;
  float turn_rate = .05;
  float turn_radius = 100;
  
  float angvel = 0;
  float angacc = 0;
  
  
  Car(float x, float y, float size_x, float size_y, float angle){
    super(x, y, size_x, size_y, angle);
    this.vel = new PVector(0, 0);
    this.acc = new PVector(0, 0);
    this.half_size = this.size.copy().mult(.5);
    this.r_matrix = new PVector[]{new PVector(cos(angle), -sin(angle)), new PVector(sin(angle), cos(angle))};
    this.r_matrix_T = transpose(r_matrix);
    updateCarInfo();
    
  }
  
  void updateCarInfo(){
    findDir();
    findWorldWheelDir();
    calcCornersCar();
  }
  
  void update(){
    
    if(pedal_down){
      //engine_fraction = 1;
    } else {
      //engine_fraction = 0;
    }
    
    if(turning != 0){
      turn(turning);
    } else {
      wheelReturn();
    }
    
    acc.set(world_wheel_dir.copy().normalize().mult(engine_max * engine_fraction));
    
    vel.limit(5);
    acc.sub(vel.copy().mult(vel.mag()*.005));
    if(brake_down){
      acc.sub(vel.copy().normalize().mult(brake_max));
      acc.limit(vel.mag());
    }
    
    vel.add(acc);
    pos.add(vel);
    addAngle(vel.mag() * wheel_turn_angle / turn_radius);
    pedal_down = false;
    updateCarInfo();
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
  
  void findWorldWheelDir(){
    this.world_wheel_dir = vecMatMult2D(r_matrix_T, PVector.fromAngle(wheel_turn_angle - HALF_PI));
  }
  
  void setEngineFrac(float f){
    engine_fraction = constrain(f, 0, 1);
  }
  
  void addEngineFrac(float f){
    engine_fraction = constrain(engine_fraction + f, 0, 1);
  }
  
  void turn(float d){ // d = -1 or 1
    wheel_turn_angle = constrain(wheel_turn_angle + d * turn_rate, -wheel_turn_max, wheel_turn_max);
    //println("!!!!!" + wheel_turn_angle);
  }
  
  void turnRight(){
    wheel_turn_angle = constrain(wheel_turn_angle + turn_rate, -wheel_turn_max, wheel_turn_max);
    println("turning right " + wheel_turn_angle);
  }
  
  void turnLeft(){
    wheel_turn_angle = constrain(wheel_turn_angle - turn_rate, -wheel_turn_max, wheel_turn_max);
    println("turning left " + wheel_turn_angle);
  }
  
  void wheelReturn(){
    if(wheel_turn_angle > 0){
      wheel_turn_angle = constrain(wheel_turn_angle - turn_rate, 0, wheel_turn_max);
    } else if(wheel_turn_angle < 0){
      wheel_turn_angle = constrain(wheel_turn_angle + turn_rate, -wheel_turn_max, 0);
    }
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
  void show(){
    if(!collided){
      fill(c);
    } else {
      fill(color(255, 0, 0));
    }
    
    noStroke();
    //translate(pos.x, pos.y);
    //rotate(angle);
    //rect(0, 0, size.x, size.y);
    translate(pos.x + half_size.x, pos.y + half_size.y);
    rotate(angle);
    rect(-half_size.x, -half_size.y, size.x, size.y);
    noFill();
    stroke(255);
    strokeWeight(1);
    triangle(-half_size.x, half_size.y, half_size.x, half_size.y, 0, -half_size.y);
    resetMatrix();
    stroke(color(0, 255, 0));
    strokeWeight(5);
    for(int i = 0; i < 4; i++){
      //point(corners[i].x, corners[i].y);
    }
    noStroke();
    fill(color(0, 155, 205));
    for(int i = 0; i < 4; i++){
      translate(corners[i].x, corners[i].y);
      if(i <= 1){
        rotate(wheel_turn_angle);
      }
      rotate(angle);
      rect(-3, -6, 6, 12);
      resetMatrix();
    }
    strokeWeight(2);
    stroke(color(255, 0, 255));
    translate(pos.x + half_size.x, pos.y + half_size.y);
    line(-dir.x * 10, -dir.y * 10,  dir.x * 30, dir.y * 30);
    
  }
}
