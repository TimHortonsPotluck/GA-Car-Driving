import java.util.Arrays;
import java.util.Comparator;

//color bgcolor = color(255, 255, 0);
color bgcolor = color(75, 75, 75);


ArrayList<Box> boxes = new ArrayList<Box>();

int popsize = 500;
float inv_popsize = 1f / popsize;

int generation = 1;

ArrayList<CarBad> pop = new ArrayList<CarBad>();
ArrayList<CarBad> nextpop = new ArrayList<CarBad>();

ArrayList<CarBad> best_carbads = new ArrayList<CarBad>();

int time_limit = 1200; // any cars still alive after this # of frames will die

int sim_speed = 1;
int normal_speed = 1;
int fast_speed = 10;

boolean stopped = false;
int counter = 1;

float world = 4; // which set of boxes to load
boolean redraw_on_gen_end = true;
PVector goal_pos;

float[] car_spawn_info;
float goal_y_center;// the center of the goal. the width of the goal is height * .2

PGraphics sim;

static int map_width = 1200;
static int map_height = 800;

static float max_dist = sqrt(map_width * map_width + map_height * map_height);
static float inv_max_dist = 1 / max_dist;


boolean showing_menu = true;
boolean continuous = false;

int graph_pos_x = 600;
int graph_pos_y = 200;
int graph_width = 500;
int graph_height = 500;
FloatList best_dists = new FloatList();
FloatList med_dists = new FloatList();
FloatList avg_dists = new FloatList();

boolean domedianwipeout = true;
boolean alwaysdomedian = true;

Button[] buttons;


void settings() {
  //size(map_width + 600, map_height);
  size(map_width, map_height);
  //fullScreen();
}

void setup(){
  background(bgcolor);
  //graph = createGraphics(graph_width, graph_height);
  //map = createGraphics(map_width, map_height);
  car_spawn_info = new float[]{50, map_height * .5 - 5, 10, 25, HALF_PI}; // use x = 395 for center
  
  buttons = new Button[5];
  Button watch1gen = new Button(100, 100, 280, 30, false){
    @Override
    public void onClick(){
      println("button watch1gen hit");
      showing_menu = false;
      //doSingleGen(true);
    }
  };
  watch1gen.text = "Watch one generation";
  watch1gen.textsize = 16;
  
  Button watchmultgen = new Button(100, 200, 280, 30, false){
    @Override
    public void onClick(){
      println("button watchcontgen hit");
      continuous = true;
      showing_menu = false;
    }
  };
  watchmultgen.text = "Watch multiple generations";
  watchmultgen.textsize = 16;
  
  Button doquickgen = new Button(100, 300, 280, 30, false){
    @Override
    public void onClick(){
      println("button doquickgen hit");
      doSingleGen(false);
    }
  };
  doquickgen.text = "Do a quick generation";
  doquickgen.textsize = 16;
  
  Button domanyquickgens = new Button(100, 400, 280, 30, true){
    @Override
    public void doToggleAction(){
      println("button domanyquickgens is toggled");
      doSingleGen(false);
    }
  };
  domanyquickgens.text = "Do quick generations continuously";
  domanyquickgens.textsize = 16;
  
  Button savebest = new Button(100, 500, 280, 30, false){
    @Override
    public void onClick(){
      println("button savebest is clicked");
      //if(generation > 1){
      //  best_carbads.get(generation - 2).nn2.serialize("bestfromgen" + str(generation));
      //}
    }
  };
  savebest.text = "Save the best car";
  savebest.textsize = 16;
  
  buttons[0] = watch1gen;
  buttons[1] = watchmultgen;
  buttons[2] = doquickgen;
  buttons[3] = domanyquickgens;
  buttons[4] = savebest;
  
  randomSeed(20);
  //randomSeed(11);
  // seed 6 is good for world 4(1 + 24 rays, {16, 16} hidddens, spawn centered, goal top, 30 boxes max
  // seed 3 is good for world 4 (1 + 8 rays, {6, 6} hiddens), spawn/goal centered, 30 boxes max
  
  
  //toMatrix(getArrayColumn(new float[][]{{0, 1}, {1, 2}, {2, 3}, {3, 4}}, 1)).printMatrix();
  //toMatrix(multiDimSubset(new float[][]{{0, 1}, {1, 2}, {2, 3}, {3, 4}}, 0, 2)).printMatrix();
  //toMatrix(new float[][]{{0, 1}, {1, 2}, {2, 3}, {3, 4}}).printMatrix();
  
  
  drawWorld();
  
  for(int i  = 0; i < popsize; i++){
    CarBad cb = new CarBad(car_spawn_info[0], car_spawn_info[1], car_spawn_info[2], car_spawn_info[3], car_spawn_info[4]);
    //cb.setDefaultColor(color(255));
    //cb.setColor(color(255));
    pop.add(cb);
  }
  
  
}

void draw(){
  
  if(showing_menu){
    showMenuScreen();
    
  } else {
    doSingleGen(true);
    
  }
  //doSingleGen(true); /////////////////////////////////////////////
  
}

void showMenuScreen(){
  background(bgcolor);
  rect(300, 600, 150, 150);
  
  for(Button b : buttons){
    b.update();
    b.show();
  }
  //println("buttons updated");
  drawGraph();
}

void doSingleGen(boolean show){
  //println("here1");
  int t0 = millis();
  int speed = show ? 1 : 10000;
  sim_speed = normal_speed;
  if(!stopped){
    if(show){
      //println("here2");
      background(bgcolor);
      for(Box b : boxes){
        b.show();
        resetMatrix();
      }
    }
    for(int i = 0; i < sim_speed * speed; i++){
      //println(counter);
      if(counter >= time_limit){
        break;
      }
      for(CarBad cb : pop){
        if(!cb.finished && !cb.collided){
          cb.checkCollided(boxes);
          cb.findNearestHits(boxes);
          if(!cb.finished && !cb.collided){
            cb.update();
            if(cb.vel == 0){
              cb.collided = true;
            }
          }
        }
      }
      counter++;
    }
    if(show){
      for(CarBad cb : pop){
        cb.show();
      }
    }
    if(!popAliveOrNotFinished()){
      if(redraw_on_gen_end){
        boxes.clear();
        drawWorld();
      }
      println("gen " + generation + " end");
      nextpop.clear();
      counter = 1;
      generation++;
      float avg_dist = 0;
      float best_dist = MAX_FLOAT;
      for(CarBad cb : pop){
        avg_dist += sqrt(cb.distsq_to_goal) * inv_popsize;
        //println(avg_dist + ", " + cb.dist_travelled + ", " + inv_popsize);
        if(cb.distsq_to_goal < best_dist){
          best_dist = cb.dist_travelled;
        }
      }
      avg_dists.append(avg_dist);
      //println("Avg dist to goal = " + avg_dist);
      //println("Lowest dist to goal = " + sqrt(best_dist));
      getNextGen();
      //for(int i = 0; i < generation - 1; i++){
      //  println(best_carbads.get(i).nn2.layers[0].weights.matrix[0][0]);
      //}
      pop.clear();
      for(CarBad cb : nextpop){
        pop.add(cb);
      }
      if(!continuous){ // if the continuous button was pressed
        showing_menu = true;
      }
    }
    if(show){
      fill(0);
      textSize(20);
      textAlign(LEFT, BOTTOM);
      text("Generation " + str(generation), map_width - 175, map_height - 40);
      text("Counter: " + str(counter), map_width - 175, map_height - 20);
    }
  }
  if(!show){
    println("Time: " + ((millis() - t0) * .001) + " seconds");
  }
}

boolean popAliveOrNotFinished(){
  if(counter >= time_limit){
    return false;
  }
  int count = 0;
  for(CarBad cb : pop){
    if(!cb.collided && !cb.finished){
      count++;
    }
  }
  return (count == 0) ? false : true;
}

void drawGraph(){
 
  stroke(255);
  noFill();
  strokeWeight(2);
  //graph_pos_x
  //graph_pos_y
  //graph_height
  //graph_width
  line(graph_pos_x, graph_pos_y, graph_pos_x, graph_pos_y + graph_height);
  line(graph_pos_x, graph_pos_y + graph_height, graph_pos_x + graph_width, graph_pos_y + graph_height);
  line(graph_pos_x, graph_pos_y, graph_pos_x + graph_width, graph_pos_y);
  line(graph_pos_x + graph_height, graph_pos_y, graph_pos_x + graph_width, graph_pos_y + graph_height);
  
  int ytick_size = 50;
  int yticks = (int)(graph_height / ytick_size);
  
  translate(graph_pos_x, graph_pos_y);
  
  
  
  if(best_dists.size() == 0){
    textAlign(CENTER, CENTER);
    textSize(72);
    fill(255);
    text("There's no data yet!", 0, -graph_height / 4, graph_width, graph_height);
    textAlign(LEFT, TOP);
    drawSmiley(graph_width / 2, graph_height *.75 - 20, 150, 255);
  } else {
    float scale =  1500 / yticks;
    float inv_scale = 1 / scale;
    for(int j = 0; j < yticks + 1; j++){
      if(j != 0 && j != yticks){
        strokeWeight(2);
        stroke(100);
        line(0, j * ytick_size, graph_width, j * ytick_size);
      }
      //strokeWeight(7);
      //stroke(color(255, 0, 0));
      //point(0, j * ytick_size);
      //point(graph_width, j * ytick_size);
      textAlign(RIGHT, CENTER);
      text((int)(j * scale), -5, graph_height - j * ytick_size);
    }
    
    
    for(int i = 0; i < generation - 1; i++){
      strokeWeight(2);
      stroke(100);
      float x1 = (i) * graph_width / (generation);
      float x2 = (i + 1) * graph_width / (generation);
      line(x2, 0, x2, graph_height);
      if(i != 0){
        stroke(color(255, 0, 0));
        line(x1, graph_height - inv_scale * ytick_size * best_dists.get(i - 1), x2, graph_height - inv_scale * ytick_size * best_dists.get(i));
        stroke(color(0, 0, 255));
        line(x1, graph_height - inv_scale * ytick_size * med_dists.get(i - 1), x2, graph_height - inv_scale * ytick_size * med_dists.get(i));
        stroke(color(255, 255, 0));
        line(x1, graph_height - inv_scale * ytick_size * avg_dists.get(i - 1), x2, graph_height - inv_scale * ytick_size * avg_dists.get(i));
      }
    }
    strokeWeight(4);
    if(best_dists.size() == 1){
      stroke(color(255, 0, 0));
      point(graph_width * .5, graph_height - inv_scale * best_dists.get(0) * ytick_size);
      stroke(color(0, 0, 255));
      point(graph_width * .5, graph_height - inv_scale * med_dists.get(0) * ytick_size);
      stroke(color(255, 255, 0));
      point(graph_width * .5, graph_height - inv_scale * avg_dists.get(0) * ytick_size);
    }
  }
  
  resetMatrix();
}


void drawSmiley(float x, float y, float w, color c){
  noFill();
  stroke(c);
  strokeWeight(2);
  ellipse(x, y, w, w);
  arc(x, y, w / 2, w / 2, QUARTER_PI, QUARTER_PI + HALF_PI);
  ellipse(x - w / 7, y - w / 8, w / 8, w / 8);
  ellipse(x + w / 7, y - w / 8, w / 8, w / 8);
}

float truncate(float num, int d){ // f is the number, d is # of decimal places
  float temp = pow(10, d); 
  return floor(num * temp) / temp;
}

void keyPressed() {
  if (key == ' ') {
    //stopped = !stopped;
    continuous = false;
  }
}

void mouseClicked() {
  if(showing_menu){
    for(Button b : buttons){
      b.update();
      if(b.mouseover){
        if(b.toggle){
          b.clicked = true;
          b.toggled = !b.toggled;
          println("b is clicked");
        } else {
          b.clicked = true;
        }
      }
    }
  }
}

void mouseReleased(){
  sim_speed = (sim_speed == normal_speed) ? fast_speed : normal_speed;
}
