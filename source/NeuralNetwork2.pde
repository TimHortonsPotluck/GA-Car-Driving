import java.io.*;

class Layer{
  int in_nodes, out_nodes;
  
  Matrix weights;
  Matrix biases;
  
  Layer(int in_nodes, int out_nodes){
    this.in_nodes = in_nodes;
    this.out_nodes = out_nodes;
    
    weights = new Matrix(out_nodes, in_nodes);
    biases = new Matrix(out_nodes, 1);
    
    weights.randomize(3);
    biases.randomize(3);
  }
  
  Matrix feed(Matrix inputs){
    if(inputs.rows == in_nodes && inputs.cols == 1){
      
    } else if(inputs.rows == 1 && inputs.cols == in_nodes){
      inputs = inputs.transpose();
    } else {
      println("inputs don't have correct dimentions");
      return null;
    }
    return weights.matrixMult(inputs).matrixAdd(biases).actFunction();
  }
  
  void serialize(FileOutputStream fileout){
    try{
      ObjectOutputStream out = new ObjectOutputStream(fileout);
      out.writeObject(this);
      out.close();
    } catch(IOException i){
      i.printStackTrace();
    }
    
  }
}

class NeuralNetwork2 {
  
  int Inodes;
  int[] Hlayers;
  int num_hiddens;
  int Onodes;
  
  Layer[] layers;
  Matrix[] layer_outs;
  
  int out_layer;
  
  float lr;
  
  NeuralNetwork2(int Inodes, int[] Hlayers, int Onodes, float lr) {
    //println("here!");
    this.lr = lr;
    this.Inodes = Inodes;
    this.Hlayers = Hlayers;
    this.Onodes = Onodes;
    num_hiddens = Hlayers.length;
    out_layer = num_hiddens + 1 - 1;
    // the + 1 - 1 is to show that the length of the array is num_hiddens + 1, 
    // but we need to subtract 1 so we don't go over the end of the array
    layers = new Layer[num_hiddens + 1];
    layer_outs = new Matrix[num_hiddens + 1];
    
    layers[0] = new Layer(Inodes, Hlayers[0]);
    for(int i = 0; i < num_hiddens - 1; i++){
      layers[i + 1] = new Layer(Hlayers[i], Hlayers[i + 1]);
      //println(i + 1 + ",!i, layers!  " + layers[i]);
    }
    layers[num_hiddens + 1 - 1] = new Layer(Hlayers[num_hiddens - 1], Onodes);
  }
  
  Matrix[] feedForward(Matrix inputs){
    
    layer_outs[0] = layers[0].feed(inputs);
    for(int i = 0; i < out_layer; i++){
      layer_outs[i + 1] = layers[i + 1].feed(layer_outs[i]);
    }
    return layer_outs;
  }
  /*
  I'M NOT BOTHERING WITH BACKPROP RIGHT NOW BECAUSE I'M JUST DOING GENETIC ALGO.
  Matrix[] backProp(Matrix inputs, Matrix targets){
    
    if(inputs.rows == input_nodes && inputs.cols == 1){
      
    } else if(inputs.rows == 1 && inputs.cols == input_nodes){
      inputs = inputs.transpose();
    } else {
      println("inputs don't have correct dimentions");
      return null;
    }
    
    if(targets.rows == output_nodes && targets.cols == 1){
      
    } else if(targets.rows == 1 && targets.cols == output_nodes){
      targets = targets.transpose();
    } else {
      println("targets don't have correct dimentions");
      return null;
    }
    
    Matrix[] from_feed = feedForward(inputs);
    Matrix hiddens = from_feed[0];
    Matrix ys = from_feed[1];
    
    Matrix output_errors = ys.matrixSub(targets);
    Matrix hidden_errors = weights_ho.transpose().matrixMult(output_errors);
    
    Matrix weight_deltas_o, weight_deltas_h, bias_deltas_o, bias_deltas_h;
    
    weight_deltas_o = output_errors.elemMult(ys).elemMult(ys.elemSub(1)).matrixMult(hiddens.transpose()).scalarMult(lr);
    weight_deltas_h = hidden_errors.elemMult(hiddens).elemMult(hiddens.elemSub(1)).matrixMult(inputs.transpose()).scalarMult(lr);
    bias_deltas_o = output_errors.elemMult(ys).elemMult(ys.elemSub(1)).scalarMult(lr);
    bias_deltas_h = hidden_errors.elemMult(hiddens).elemMult(hiddens.elemSub(1)).scalarMult(lr);
    
    //weights_ho.printMatrix();
    //weight_deltas_o.printMatrix();
    
    
    return new Matrix[]{weight_deltas_o, weight_deltas_h, bias_deltas_o, bias_deltas_h};
  }
  */
  
  //Matrix[] backProp(Matrix inputs, Matrix targets){
  //  /*
  //  if(inputs.rows == input_nodes && inputs.cols == 1){
      
  //  } else if(inputs.rows == 1 && inputs.cols == input_nodes){
  //    inputs = inputs.transpose();
  //  } else {
  //    println("inputs don't have correct dimentions");
  //    return null;
  //  }
    
  //  if(targets.rows == output_nodes && targets.cols == 1){
      
  //  } else if(targets.rows == 1 && targets.cols == output_nodes){
  //    targets = targets.transpose();
  //  } else {
  //    println("targets don't have correct dimentions");
  //    return null;
  //  }
  //  */
    
  //  Matrix[] from_feed = feedForward(inputs);
  //  Matrix hiddens = from_feed[0];
  //  Matrix ys = from_feed[1];
    
  //  Matrix output_errors = ys.matrixSub(targets);
  //  Matrix hidden_errors = weights_ho.transpose().matrixMult(output_errors);
    
  //  Matrix weight_deltas_o, weight_deltas_h, bias_deltas_o, bias_deltas_h;
    
  //  weight_deltas_o = output_errors.elemMult(ys).elemMult(ys.elemSub(1)).matrixMult(hiddens.transpose()).scalarMult(lr);
  //  weight_deltas_h = hidden_errors.elemMult(hiddens).elemMult(hiddens.elemSub(1)).matrixMult(inputs.transpose()).scalarMult(lr);
  //  bias_deltas_o = output_errors.elemMult(ys).elemMult(ys.elemSub(1)).scalarMult(lr);
  //  bias_deltas_h = hidden_errors.elemMult(hiddens).elemMult(hiddens.elemSub(1)).scalarMult(lr);
    
  //  //weights_ho.printMatrix();
  //  //weight_deltas_o.printMatrix();
    
    
  //  return new Matrix[]{weight_deltas_o, weight_deltas_h, bias_deltas_o, bias_deltas_h};
  //}

  
  void mutate(float ma, float mc){ // ma = mutate amt, mc = mutation chance per weight/bias
    //println("checking mutations");
    for(int l = 0; l < out_layer + 1; l++){ // l for layer
      Matrix tempweights = layers[l].weights;
      Matrix tempbiases = layers[l].biases;
      for(int j = 0; j < tempweights.rows; j++){
        for(int i = 0; i < tempweights.cols; i++){
          if(random(1) < mc){
            //println("weight " + l + " " + j + " " + i + " before: " + tempweights.matrix[j][i]);
            tempweights.matrix[j][i] += (random(2) - 1) * ma;
            //println("weight " + l + " " + j + " " + i + " after: " + tempweights.matrix[j][i]);
          }
        }
      }
      
      for(int j = 0; j < tempbiases.rows; j++){
        for(int i = 0; i < tempbiases.cols; i++){
          if(random(1) < mc){
            //println("bias " + l + " " + j + " " + i + " before: " + tempbiases.matrix[j][i]);
            tempbiases.matrix[j][i] += (random(2) - 1) * ma;
            //println("bias " + l + " " + j + " " + i + " after: " + tempbiases.matrix[j][i]);
          }
        }
      }
      layers[l].weights = tempweights;
      layers[l].biases = tempbiases;
    }
  }
  
  void crossover(NeuralNetwork2 parent){
    for(int l = 0; l < out_layer + 1; l++){ // l for layer
      Matrix tempweights = layers[l].weights;
      Matrix tempbiases = layers[l].biases;
      Matrix pweights = parent.layers[l].weights;
      Matrix pbiases = parent.layers[l].biases;
      for(int j = 0; j < tempweights.rows; j++){
        for(int i = 0; i < tempweights.cols; i++){
          if(random(1) < .5){
            tempweights.matrix[j][i] = pweights.matrix[j][i];
          }
        }
      }
      
      for(int j = 0; j < tempbiases.rows; j++){
        for(int i = 0; i < tempbiases.cols; i++){
          if(random(1) < .5){
            tempbiases.matrix[j][i] = pbiases.matrix[j][i];
          }
        }
      }
      layers[l].weights = tempweights;
      layers[l].biases = tempbiases;
    }
  }
  /*
  void train(Matrix inputs, Matrix targets){
    
    Matrix[] from_backprop = backProp(inputs, targets);
    Matrix weight_deltas_o = from_backprop[0];
    Matrix weight_deltas_h = from_backprop[1];
    Matrix bias_deltas_o = from_backprop[2];
    Matrix bias_deltas_h = from_backprop[3];
    
    weights_ho = weights_ho.matrixAdd(weight_deltas_o);
    weights_ih = weights_ih.matrixAdd(weight_deltas_h);
    biases_ho = biases_ho.matrixAdd(bias_deltas_o);
    biases_ih = biases_ih.matrixAdd(bias_deltas_h);
  }
  */
  Matrix check(Matrix inputs){
    Matrix[] from_feed = feedForward(inputs);
    Matrix outputs = from_feed[out_layer];
    return outputs;
  }
  
  NeuralNetwork2 copyNN(){
    NeuralNetwork2 nn2copy = new NeuralNetwork2(Inodes, Hlayers, Onodes, lr);
    for(int l = 0; l < out_layer + 1; l++){ // l for layer
      Matrix tempweights = layers[l].weights;
      Matrix tempbiases = layers[l].biases;
      for(int j = 0; j < tempweights.rows; j++){
        for(int i = 0; i < tempweights.cols; i++){
          nn2copy.layers[l].weights.matrix[j][i] = layers[l].weights.matrix[j][i];
        }
      }
      for(int j = 0; j < tempbiases.rows; j++){
        for(int i = 0; i < tempbiases.cols; i++){
          nn2copy.layers[l].biases.matrix[j][i] = layers[l].biases.matrix[j][i];
        }
      }
    }
    return nn2copy;
  }
  
  void serialize(String filename){
    try{
      FileOutputStream fileout = new FileOutputStream(filename);
      //ObjectOutputStream out = new ObjectOutputStream(fileout);
      //out.writeObject(this);
      //out.close();
      for(int l = 0; l < layers.length; l++){
        layers[l].serialize(fileout);
        //ObjectOutputStream out = new ObjectOutputStream(fileout);
      }
      fileout.close();
    } catch(IOException i){
      i.printStackTrace();
    }
  }
}
