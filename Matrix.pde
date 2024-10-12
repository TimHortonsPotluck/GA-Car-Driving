Matrix toMatrix(float[][] array){
  Matrix result = new Matrix(array.length, array[0].length);
  result.matrix = array;
  return result;
}

Matrix toMatrix(float[] array){
  Matrix result = new Matrix(array.length, 1);
  for(int i = 0; i < array.length; i++){
    result.matrix[i][0] = array[i];
  }
  return result;
}

float[] toArray(Matrix mat){ // only for the outputs!
  //mat.printMatrix();
  int[] dims = new int[]{mat.matrix.length, mat.matrix[0].length}; // {rows, cols}
  //println(dims[0] + ", " + dims[1]);
  float[] array;
  if(dims[0] == 1){
    array = new float[mat.matrix.length];
    array = mat.matrix[0];
  } else if(dims[1] == 1){
    array = new float[mat.matrix[0].length];
    array = mat.transpose().matrix[0];
  } else {
    println("Can only be used on a vector!");
    array = new float[]{0}; 
  }
  return array;
}

class Matrix {
  int rows;
  int cols;
  float[][] matrix;
  
  Matrix(int rows, int cols){
    this.rows = rows;
    this.cols = cols;
    matrix = new float[rows][cols];
    
    for(int j = 0; j < rows; j++){
      for(int i = 0; i < cols; i++){
        matrix[j][i] = 1;
      }
    }
  }
  
  int getRows(){
    return matrix.length;
  }
  
  int getCols(){
    return matrix[0].length;
  }
  
  Matrix copy(){
    Matrix copy = new Matrix(rows, cols);
    for(int j = 0; j < rows; j++){
      for(int i = 0; i < cols; i++){
        copy.matrix[j][i] = matrix[j][i];
      }
    }
    return copy;
  }
  
  float sigmoid(float x){
    return 1 / (1 + exp(-x));
  }
  
  void randomize(float mag){ // ranges from -mag to +mag
    for(int j = 0; j < rows; j++){
      for(int i = 0; i < cols; i++){
        matrix[j][i] = random(2 * mag) - mag;
      }
    }
  }
  
  Matrix scalarMult(float scalar){
    Matrix result = new Matrix(rows, cols);
    for(int j = 0; j < rows; j++){
      for(int i = 0; i < cols; i++){
        result.matrix[j][i] = matrix[j][i] * scalar;
      }
    }
    return result;
  }
  
  Matrix matrixMult(Matrix m2){
    //println("m1 size:" + str(m1.rows) + ", " + str(m1.cols));
    //println("m2 size:" + str(m2.rows) + ", " + str(m2.cols));
    Matrix result = new Matrix(rows, m2.cols);
    for (int j = 0; j < rows; j++){
      for (int i = 0; i < m2.cols; i++){
        
        float elem = 0;
        for (int e = 0; e < m2.rows; e++){
          //println(e + ", " + j + ", " + i);
          elem += matrix[j][e] * m2.matrix[e][i];
          //print(m1.matrix[j][e] + m2.matrix[e][i]);
        }
        result.matrix[j][i] = elem;
        
      }
    }
    return result;
  }
  
  Matrix elemMult(Matrix m){
    Matrix result = new Matrix(rows, cols);
    for(int j = 0; j < rows; j++){
      for(int i = 0; i < cols; i++){
        result.matrix[j][i] = matrix[j][i] * m.matrix[j][i];
      }
    }
    return result;
  }
  
  Matrix elemAdd(float scalar){
    Matrix result = new Matrix(rows, cols);
    for(int j = 0; j < rows; j++){
      for(int i = 0; i < cols; i++){
        result.matrix[j][i] = matrix[j][i] + scalar;
      }
    }
    return result;
  }
  
  Matrix matrixAdd(Matrix m1){
    Matrix result = new Matrix(rows, cols);
    for(int j = 0; j < rows; j++){
      for(int i = 0; i < cols; i++){
        result.matrix[j][i] = matrix[j][i] + m1.matrix[j][i];
      }
    }
    return result;
  }
  
  Matrix elemSub(float scalar){
    Matrix result = new Matrix(rows, cols);
    for(int j = 0; j < rows; j++){
      for(int i = 0; i < cols; i++){
        result.matrix[j][i] = matrix[j][i] - scalar;
      }
    }
    return result;
  }
  
  Matrix matrixSub(Matrix m1){
    Matrix result = new Matrix(rows, cols);
    for(int j = 0; j < rows; j++){
      for(int i = 0; i < cols; i++){
        result.matrix[j][i] = matrix[j][i] - m1.matrix[j][i];
      }
    }
    return result;
  }
  
  Matrix transpose(){
    Matrix transposed = new Matrix(cols, rows); // chaninging dimentions
    for(int j = 0; j < rows; j++){
      for(int i = 0; i < cols; i++){
        transposed.matrix[i][j] = matrix[j][i];
      }
    }
    return transposed;
  }
  
  Matrix actFunction(){
    Matrix result = new Matrix(rows, cols);
    for(int j = 0; j < rows; j++){
      for(int i = 0; i < cols; i++){
        result.matrix[j][i] = sigmoid(matrix[j][i]);
      }
    }
    return result;
  }
  
  void printMatrix(){
    for(int j = 0; j < rows; j++){
      for(int i = 0; i < cols; i++){
        print(matrix[j][i] + " ");
      }
      println("");
    }
  }
}
