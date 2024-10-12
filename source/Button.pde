class Button{
  
  PVector pos;
  PVector size;
  PVector half_size;
  PVector center;
  
  boolean toggle;
  
  boolean mouseover = false;
  boolean clicked = false;
  boolean toggled = false;
  
  color c0 = color(100, 100, 255);
  color c_over = color(150, 150, 255);
  color c_tog = color(0, 0, 100);
  color c = c0;
  
  String text = "";
  int textsize = 10;
  
  color textc0 = color(0);
  color textc_tog = color(255);
  color textc = textc0;
  
  Button(float x, float y, float size_x, float size_y, boolean toggle){
    this.pos = new PVector(x, y);
    this.size = new PVector(size_x, size_y);
    this.half_size = this.size.copy().mult(.5);
    this.center = pos.copy().add(half_size);
    this.toggle = toggle;
  }
  
  void update(){
    mouseover = checkMouseOver();
    c = c0;
    if(clicked){
      onClick();
    }
    if(toggled){
      doToggleAction();
    }
    clicked = false;
  }
  
  boolean checkMouseOver(){
    return !(mouseX <= pos.x || mouseX >= pos.x + size.x || mouseY <= pos.y ||mouseY >= pos.y + size.y);
  }
  
  public void onMouseOver(){
    
    
    
  }
  
  public void onClick(){
    
    
    
  }
  
  public void doToggleAction(){
    
    
  }
  
  void show(){
    textc = textc0;
    if(mouseover){
      c = c_over;
    }
    if(toggled){
      c = c_tog;
      textc = textc_tog;
    }
    fill(c);
    noStroke();
    rect(pos.x, pos.y, size.x, size.y);
    fill(textc);
    textSize(textsize);
    textAlign(CENTER, CENTER);
    text(text, pos.x, pos.y - (textsize / 10), size.x, size.y);
    textAlign(LEFT, TOP);
  }
  
  
  
  
  
  
}
