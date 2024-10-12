
void calcFitness(){
  float sum = 0;
  for(CarBad cb : pop){
    if(world == 2){
      cb.fitness_not_norm = pow(cb.dist_travelled, 2);
    } else {
      cb.fitness_not_norm = pow((cb.max_dist * cb.max_dist) - cb.distsq_to_goal, 1) * .001 * ((cb.num_dir_changes == 0) ? 0 : 1);
      if(cb.finished){
        cb.fitness_not_norm *= 2;
      }
    }
    if(cb.finished){
      //println("finished fitness_not_norm = " + cb.fitness_not_norm);
    } else {
      //println("unfinished fitness_not_norm = " + cb.fitness_not_norm);
    }
    //println(cb.num_dir_changes);
    sum += cb.fitness_not_norm;
  }
  //println("sum = " + sum);
  float fit_sum = 0;
  float inv_sum = 1 / sum;
  for(CarBad cb : pop){
    cb.fitness = cb.fitness_not_norm * inv_sum;
    //println(cb.fitness + ", " + cb.num_dir_changes);
    cb.fitness_w_index = new float[]{cb.fitness, pop.indexOf(cb)};
    //println(cb.fitness);
    if(cb.finished){
      //println("finished fitness = " + cb.fitness);
    } else {
      //println("unfinished fitness = " + cb.fitness);
    }
    fit_sum += cb.fitness;
  }
  //println(sum);
  //println("fit_sum = " + fit_sum);
}

CarBad doCrossover(float ma, float mc){ // ma = mutate amt, mc = mutation chance per weight/bias
  int indexA = 0;
  float rnd = random(1);
  while(rnd >= 0){
    if(indexA == popsize){
      indexA--;
    }
    rnd -= pop.get(indexA).fitness;
    indexA++;
  }
  indexA--;
  
  int indexB = 0;
  rnd = random(1);
  while(rnd >= 0){
    if(indexB == popsize){
      indexB--;
    }
    rnd -= pop.get(indexB).fitness;
    indexB++;
  }
  indexB--;
  
  if(indexA != indexB){
    //maybe add
  } else {
    //maybe add
  }
  
  CarBad parentA = pop.get(indexA);
  CarBad parentB = pop.get(indexB);
  parentA.crossover(parentB);
  parentA.mutateNN(ma, mc);
  CarBad newcb = new CarBad(car_spawn_info[0], car_spawn_info[1], car_spawn_info[2], car_spawn_info[3], car_spawn_info[4], parentA.copyNN());
  return newcb;
}

CarBad doCrossoverRandom(float ma, float mc, float[] carstopickfrom){
  int indexA = (int)random(carstopickfrom.length);
  int indexB = (int)random(carstopickfrom.length);
  CarBad parentA = pop.get(indexA);
  CarBad parentB = pop.get(indexB);
  parentA.crossover(parentB);
  parentA.mutateNN(ma, mc);
  CarBad newcb = new CarBad(car_spawn_info[0], car_spawn_info[1], car_spawn_info[2], car_spawn_info[3], car_spawn_info[4], parentA.copyNN());
  return newcb;
}

float[][] sortPopFitessArray(){
  float[][] pop_fitness_w_index = new float[popsize][2];
  for(int i = 0; i < pop.size(); i++){
    pop_fitness_w_index[i] = pop.get(i).fitness_w_index;
  }
  
  Arrays.sort(pop_fitness_w_index, new Comparator<float[]>() {      
    @Override
    public int compare(float[] o1, float[] o2) {
      return Float.compare(o2[0], o1[0]);
    }
  });
  
  return pop_fitness_w_index;
}

int findCarBadIndex(float[][] fitnessarray, int place){ // finds index of car in specific "place", i.e. place 0 is the best car
  
  int index = (int)fitnessarray[place][1];
  return index;
}

CarBad pickCarBad(float ma, float mc){ // ma = mutate amt, mc = mutation chance per weight/bias
  int index = 0;
  float rnd = random(1);
  while(rnd > 0){
    if(index == popsize){
      index--;
    }
    rnd -= pop.get(index).fitness;
    index++;
  }
  index--;
  
  CarBad cb = pop.get(index);
  cb.mutateNN(ma, mc);
  CarBad newcb = new CarBad(car_spawn_info[0], car_spawn_info[1], car_spawn_info[2], car_spawn_info[3], car_spawn_info[4], cb.copyNN());
  //newcb.setDefaultColor(color(0));
  //newcb.setColor(color(0));
  return newcb;
}

CarBad pickCarBad(float ma, float mc, int index){ // adds car from specific index
  CarBad cb = pop.get(index);
  cb.mutateNN(ma, mc);
  CarBad newcb = new CarBad(car_spawn_info[0], car_spawn_info[1], car_spawn_info[2], car_spawn_info[3], car_spawn_info[4], cb.copyNN());
  newcb.setDefaultColor(color(0));
  newcb.setColor(color(0));
  return newcb;
}

void getNextGen(){
  calcFitness();
  float[][] fitnessarray = sortPopFitessArray();
  int best_index = findCarBadIndex(fitnessarray, 0);
  int med_index = findCarBadIndex(fitnessarray, (popsize / 2) - 1); // median
  best_carbads.add(pop.get(best_index));
  best_dists.append(sqrt(pop.get(best_index).distsq_to_goal));
  med_dists.append(sqrt(pop.get(med_index).distsq_to_goal));
  //println(med_dists);
  
  float ma = 1;
  float mc = 1;
  //if(avg_dists.get(avg_dists.size() - 1) <= map_height * .1){
  //  ma *= .25;
  //  mc *= .25;
  //}
  float[] fitnessarray_tomed = getArrayColumn(multiDimSubset(fitnessarray, 0, popsize / 2), 1);
  //println(pop.get((int)fitnessarray_tomed[0]).distsq_to_goal);
  if(alwaysdomedian && med_dists.get(med_dists.size() - 1) < 500){
    if(med_dists.get(med_dists.size() - 1) < map_height * .1){
      for(int i = 0; i < popsize; i++){
        nextpop.add(doCrossoverRandom(ma * .1, mc * .1, fitnessarray_tomed));
        //nextpop.add(pickCarBad(ma, mc));
      }
    } else {  
      for(int i = 0; i < popsize; i++){
        nextpop.add(doCrossoverRandom(ma * .5, mc * .5, fitnessarray_tomed));
        //nextpop.add(pickCarBad(ma, mc));
      }
    }
  } else {
    if(domedianwipeout){
      if(med_dists.get(med_dists.size() - 1) < map_height * .1){
        for(int i = 0; i < popsize; i++){
          println("median finished");
          nextpop.add(doCrossoverRandom(ma * .5, mc * .5, fitnessarray_tomed));
          //nextpop.add(pickCarBad(ma, mc));
        }
      } else {
        nextpop.add(pickCarBad(.1, 0, best_index));
        for(int i = 0; i < popsize - 1; i++){
          //nextpop.add(pickCarBad(.5 * mutationRateFunc(generation), .5 * mutationRateFunc(generation)));
          nextpop.add(doCrossover(ma * .5, mc * .5));
          //nextpop.add(pickCarBad(ma, mc));
        }
      }
    } else {
      nextpop.add(pickCarBad(.1, 0, best_index));
      for(int i = 0; i < popsize - 1; i++){
        //findCarBadIndex(fitnessarray, i);
        //nextpop.add(pickCarBad(.5 * mutationRateFunc(generation), .5 * mutationRateFunc(generation)));
        nextpop.add(doCrossover(ma * .5, mc * .5));
        //nextpop.add(pickCarBad(ma, mc));
      }
    }
  }
}

float[][] multiDimSubset(float[][] array, int start, int count){
  float[][] temp = new float[count][array[0].length];
  for(int i = start; i < count; i++){
    for(int j = 0; j < temp[0].length; j++){
      //println(i + ", " + j);
      temp[i][j] = array[i][j];
    }  
  }
  return temp;
}

float[] getArrayColumn(float[][] array, int col){
  float[] temp = new float[array.length];
  for(int i = 0; i < temp.length; i++){
    temp[i] = array[i][col];
  }
  return temp;
}

float mutationRateFunc(float g){ // g is generation
  return .5 * ((1 / sqrt(g)) + (1.5 / (1 + exp(.1733* (g - 5))))); // the values have been chosen so that at g = 1, its ~1
}
