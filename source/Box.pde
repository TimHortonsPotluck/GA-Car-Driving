class Box{
  
  PVector pos;
  float angle;
  PVector[] r_matrix;
  PVector[] r_matrix_T;
  
  PVector size;
  PVector half_size;
  PVector center;
  
  float max_extent_from_center_sq;
  
  PVector[] corners = new PVector[4];
  
  boolean collided = false;
  boolean collidable = true;
  
  color c0 = color(20, 20, 255);
  color c = c0;
  
  Box(float x, float y, float size_x, float size_y, float angle){
    this.pos = new PVector(x, y);
    this.size = new PVector(size_x, size_y);
    this.half_size = this.size.copy().mult(.5);
    this.angle = angle;
    this.max_extent_from_center_sq = pow(half_size.x + 13 + 5, 2) + pow(half_size.y + 13 + 5, 2);
    this.r_matrix = new PVector[]{new PVector(cos(angle), -sin(angle)), new PVector(sin(angle), cos(angle))};
    this.r_matrix_T = transpose(r_matrix);
    calcCorners();
    this.center = (pos.copy().add(corners[3])).mult(.5);
  }
  
  void update(){
    //calcCorners();
  }
  
  void calcCorners(){
    this.corners[0] = new PVector(pos.x, pos.y); // this is always the case
    if(angle == 0){
      this.corners[1] = new PVector(pos.x + size.x, pos.y);
      this.corners[2] = new PVector(pos.x, pos.y + size.y);
      this.corners[3] = new PVector(pos.x + size.x, pos.y + size.y);
    } else {
      this.corners[1] = vecMatMult2D(r_matrix_T, new PVector(size.x, 0)).add(pos);
      this.corners[2] = vecMatMult2D(r_matrix_T, new PVector(0, size.y)).add(pos);
      this.corners[3] = vecMatMult2D(r_matrix_T, new PVector(size.x, size.y)).add(pos);
    }
  }
  
  
  boolean checkBoxCollision(Box self, Box other){
    for(int i = 0; i < 4; i++){
      if(checkCollisionOA(other.corners[i].x, other.corners[i].y, self)){
        return true;
      }
    }
    return false;
  }
  
  boolean checkCollisionAA(float px, float py, PVector pos_, PVector size_){ // coords of point, box position/size
    return !(px <= pos_.x || px >= pos_.x + size_.x || py <= pos_.y || py >= pos_.y + size_.y);
  }
  
  boolean checkCollisionOA(float px, float py, Box self){
    PVector p = new PVector(px, py).copy().sub(self.corners[0]);
    PVector _p = vecMatMult2D(self.r_matrix, p);
    return checkCollisionAA(_p.x, _p.y, new PVector(0, 0), self.size);
  }
  
  
  PVector vecMatMult2D(PVector[] mat, PVector vec){
    PVector p = new PVector();
    p.set(mat[0].copy().mult(vec.x).add(mat[1].copy().mult(vec.y)));
    return p;
  }
  
  PVector[] matMatMult2D(PVector[] mat1, PVector[] mat2){
    PVector[] m = new PVector[2];
    PVector[] mat1_T = transpose(mat1);
    m[0] = new PVector(mat2[0].dot(mat1_T[0]), mat2[0].dot(mat1_T[1]));
    m[1] = new PVector(mat2[1].dot(mat1_T[0]), mat2[1].dot(mat1_T[1]));
    return m;
  }
  
  PVector[] matPower2D(PVector[] mat, int p){ // raise a matrix to a power
    PVector[] temp = mat;
    for(int i = 0; i < p - 1; i++){
      temp = matMatMult2D(temp, mat);
    }
    return temp;
  }
  
  PVector[] transpose(PVector[] mat){
    return new PVector[]{new PVector(mat[0].x, mat[1].x), new PVector(mat[0].y, mat[1].y)};
  }
  
  void setAngle(float a){
    angle = a;
    r_matrix = new PVector[]{new PVector(cos(a), -sin(a)), new PVector(sin(a), cos(a))};
    this.r_matrix_T = transpose(r_matrix);
    calcCorners();
  }
  
  void addAngle(float a){
    angle += a;
    r_matrix = new PVector[]{new PVector(cos(angle), -sin(angle)), new PVector(sin(angle), cos(angle))};
    this.r_matrix_T = transpose(r_matrix);
    calcCorners();
  }
  
  void setColor(color c){
    this.c = c;
  }
  
  void setDefaultColor(color c){
    this.c0 = c;
  }
  
  void resetColor(){
    this.c = c0;
  }
  
  void show(){
    if(!collided){
      fill(c);
    } else {
      fill(color(255, 0, 0));
    }
    noStroke();
    //stroke(0);
    strokeWeight(2);
    translate(pos.x, pos.y);
    rotate(angle);
    rect(0, 0, size.x, size.y);
    resetMatrix();
    //stroke(0);
    //strokeWeight(5);
    //for(int i = 0; i < 4; i++){
    //  point(corners[i].x, corners[i].y);
    //}
    
    //translate(center.x, center.y);
    //noFill();
    //strokeWeight(2);
    //ellipse(0, 0, 2 * sqrt(max_extent_from_center_sq), 2 * sqrt(max_extent_from_center_sq));
    //resetMatrix();
    
  }
  void show(PGraphics pg){
    pg.beginDraw();
    if(!collided){
      pg.fill(c);
    } else {
      pg.fill(color(255, 0, 0));
    }
    pg.noStroke();
    //stroke(0);
    pg.strokeWeight(2);
    pg.translate(pos.x, pos.y);
    pg.rotate(angle);
    pg.rect(0, 0, size.x, size.y);
    pg.resetMatrix();
    //stroke(0);
    //strokeWeight(5);
    //for(int i = 0; i < 4; i++){
    //  point(corners[i].x, corners[i].y);
    //}
    
    //translate(center.x, center.y);
    //noFill();
    //strokeWeight(2);
    //ellipse(0, 0, 2 * sqrt(max_extent_from_center_sq), 2 * sqrt(max_extent_from_center_sq));
    //resetMatrix();
    pg.endDraw();
  }
}
