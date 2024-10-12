

void drawWorld(){
  if(world == 0){
    boxes.add(new Box(10, 10, 100, 10, 0));
    boxes.add(new Box(10, 10, 100, 10, HALF_PI));
    boxes.add(new Box(120, 10, 100, 10, HALF_PI));
    
    boxes.add(new Box(10, 110, 100, 10, HALF_PI));
    boxes.add(new Box(120, 110, 100, 10, HALF_PI));
    
    boxes.add(new Box(10, 210, 100, 10, HALF_PI - .1));
    boxes.add(new Box(120, 210, 100, 10, HALF_PI - .1));
    
    boxes.add(new Box(10 + 9, 310, 100, 10, HALF_PI - .2));
    boxes.add(new Box(120 + 9, 310, 100, 10, HALF_PI - .2));
  } else if(world == 1){
    for(int i = 0; i < 40; i++){
      boxes.add(new Box(random(map_width), random(map_height * 1) + map_height * .0, (random(20) + 10) * 5, (random(20) + 10) * 5, random(TWO_PI)));
    }
    Box spawn_mask = new Box(150, 350, 150, 100, 0); // covers spawn area to make sure cars aren't immediately collided
    Box goal_mask = new Box(1100, 320, 100, 160, 0);
    for(int i = boxes.size() - 1; i >= 0; i--){ // checking collisions with the spawn mask
      Box b = boxes.get(i);
      if(spawn_mask.checkBoxCollision(spawn_mask, b)){
        boxes.remove(b);
      } else if (b.checkBoxCollision(b, spawn_mask)){
        boxes.remove(b);
      } else if (goal_mask.checkBoxCollision(goal_mask, b)){
        boxes.remove(b);
      } else if (b.checkBoxCollision(b, goal_mask)){
        boxes.remove(b);
      }
    }
    spawn_mask = null;
    goal_mask = null;
    boxes.add(new Box(0, map_height - 10, map_width, 10, 0));
    boxes.add(new Box(0, 0, 2 * map_width / 5, 10, 0));
    boxes.add(new Box(3 * map_width / 5, 0, 2 * map_width / 5, 10, 0));
    boxes.add(new Box(0, 0, 10, map_height, 0));
    boxes.add(new Box(map_width - 10, 0, 10, map_height, 0));
  } else if(world == 2){
    for(int i = 0; i < 40; i++){
      boxes.add(new Box(random(map_width), random(map_height * 1) + map_height * .0, (random(20) + 10) * 5, (random(20) + 10) * 5, random(TWO_PI)));
    }
    Box spawn_mask = new Box(150, 350, 150, 100, 0); // covers spawn area to make sure cars aren't immediately collided
    for(int i = boxes.size() - 1; i >= 0; i--){ // checking collisions with the spawn mask
      Box b = boxes.get(i);
      if(spawn_mask.checkBoxCollision(spawn_mask, b)){
        boxes.remove(b);
      } else if (b.checkBoxCollision(b, spawn_mask)){
        boxes.remove(b);
      }
    }
    spawn_mask = null;
    //boxes.add(new Box(600, 400, 100, 100, 0)); testing
    boxes.add(new Box(0, 0, map_width, 10, 0));
    boxes.add(new Box(0, map_height - 10, map_width, 10, 0));
    boxes.add(new Box(0, 0, 10, map_height, 0));
    boxes.add(new Box(map_width - 10, 0, 10, map_height, 0));
  } else if(world == 3){
    boxes.add(new Box(0, 0, map_width, 10, 0));
    boxes.add(new Box(0, map_height - 10, map_width, 10, 0));
    boxes.add(new Box(0, 0, 10, map_height, 0));
    boxes.add(new Box(map_width - 10, 0, 10, map_height, 0));
  } else if(world == 4){
    for(int i = 0; i < 30; i++){ // i < 25 works well
      world4BoxSpawner(0);
    }
    
    goal_y_center = random(map_height * .1 + 10, map_height * .9 - 10);
    goal_pos = new PVector(map_width, goal_y_center);
    //50, 395, 10, 25, HALF_PI
    Box spawn_mask = new Box(-100, car_spawn_info[1] - 70, 300, 150, 0); // covers spawn area to make sure cars aren't immediately collided
    Box goal_mask = new Box(map_width - 100, goal_y_center - map_height * .1, 200, map_height * .2, 0);
    spawn_mask.c = color(255, 0, 0);
    goal_mask.c = color(255, 0, 0);
    for(int i = boxes.size() - 1; i >= 0; i--){ // checking collisions with the spawn mask
      Box b = boxes.get(i);
      if(spawn_mask.checkBoxCollision(spawn_mask, b)){
        boxes.remove(b);
      } else if (b.checkBoxCollision(b, spawn_mask)){
        boxes.remove(b);
      } else if (goal_mask.checkBoxCollision(goal_mask, b)){
        boxes.remove(b);
      } else if (b.checkBoxCollision(b, goal_mask)){
        boxes.remove(b);
      }
    }
    spawn_mask = null;
    goal_mask = null;
    
    //Box goal = new Box(1200 - 10, goal_y_center - map_height * .1, 20, map_height * .2, 0);
    //goal.c = color(255, 255, 255);
    //goal.collidable = false;
    //boxes.add(goal);
    
    boxes.add(new Box(0, 0, map_width, 10, 0));
    boxes.add(new Box(0, map_height - 10, map_width, 10, 0));
    boxes.add(new Box(0, 0, 10, map_height, 0));
    boxes.add(new Box(map_width - 10, 0, 10, goal_y_center - map_height * .1, 0));
    boxes.add(new Box(map_width - 10, goal_y_center + map_height * .1, 10, map_height * .9 - goal_y_center, 0));
    //while(!stopped){
    //  spawn_mask.show();
    //  goal_mask.show();
    //  for(Box b : boxes){
    //    b.show();
    //  }
    //}
    
    
  }
}

void world4BoxSpawner(int counter){
  if(boxes.size() == 0){
    boxes.add(new Box(random(map_width), random(map_height), (random(2) + 1) * 50, (random(2) + 1) * 50, random(TWO_PI)));
  } else {
    float x, y, w, h;
    x = random(map_width);
    y = random(map_height);
    w = (random(2) + 1) * 50;
    h = (random(2) + 1) * 50;
    Box bnew = new Box(x, y, w, h, random(TWO_PI));
    boolean can_add = true;
    for(Box b : boxes){
      if(bnew.center.copy().sub(b.center).magSq() <= (.25 * (w + b.size.x + 15) * (w + b.size.x + 15)) + (.25 * (h + b.size.y + 15) * (h + b.size.y + 15))){
        can_add = false;
      }
    }
    //for loop ends
    if(can_add){
      boxes.add(bnew);
    } else {
      if(counter < 50){
        world4BoxSpawner(counter + 1);
      }
    }
  }
}
