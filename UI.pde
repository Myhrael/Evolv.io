abstract class AbstractUI{
  protected Rect rect;
  protected color background;
  protected boolean bgEnabled;
  
  private boolean enabled, visible;
  private AbstractContainer parent;
  private int stroke;

  protected AbstractUI(Rect rect){
    this.rect = rect;
    enabled = true;
    visible = true;
    parent = null;
    background = color(255);
    bgEnabled = false;
    stroke = 0;
  }
  
  public void draw(){
    if(stroke == 0) noStroke();
    else stroke(stroke);
    
    if(bgEnabled){
      fill(background);
      rect(rect.x, rect.y, rect.w, rect.h);
    }
  }
  public void update(){ print( this+" update"); }
  public boolean click(){ return false; }
  
  public void enable(){ enabled = true; }
  public void enable(boolean enabled){ this.enabled = enabled; }
  public boolean isEnabled(){ return enabled; }
  public void setVisible(boolean visible){ this.visible = visible; }
  public boolean isVisible(){ return visible; }
  
  public void setBackground(color c){ background = c; }
  public void enableBackground(){ bgEnabled = true; }
  public void enableBackground(boolean b){ bgEnabled = b; }
  
  public void setStroke(int size){ stroke = size; }
  
  public AbstractUI getParent(){ return parent; }
  protected void setParent(AbstractContainer parent){ this.parent = parent; }
  
  public Rect getRect(){ return rect; }
  protected Rect absoluteRect(){
    Rect absolute;
    if(parent != null){
      float[] refPos = parent.referencePos();
      absolute = new Rect(refPos[0]+rect.x, refPos[1]+rect.y, rect.w, rect.h);
      if(parent.rectMode == CENTER || parent.rectMode == RADIUS){
        absolute.x -= rect.w/2;
        absolute.y -= rect.h/2;
      }
    } else absolute = rect;
    return absolute;
  }
  public boolean contains(float x, float y){ return absoluteRect().contains(x, y); }
}

abstract class AbstractContainer extends AbstractUI{
  private ArrayList<AbstractUI> children;
  protected int rectMode;
  
  protected AbstractContainer(Rect rect){
    super(rect);
    children = new ArrayList<AbstractUI>();
    rectMode = CORNER;
  }
  
  public void draw(){
    super.draw();
    
    if(this.isVisible()){
      pushMatrix();
      if(rectMode == CORNER)
        translate(rect.x, rect.y);
      else if(rectMode == CENTER || rectMode == RADIUS)
        translate(rect.x+rect.w/2, rect.y+rect.h/2);
      
      for(AbstractUI child : this.children){
        rectMode(rectMode);
        child.draw();
      }
      
      popMatrix();
    }
  }
  
  public void update(){
    super.update();
    
    for(AbstractUI child : this.children){
      child.update();
    }
  }
  
  public boolean click(){
    super.click();
    
    if(this.isEnabled() && this.contains(mouseX, mouseY)){
      for(AbstractUI child : this.children){
        if(child.contains(mouseX, mouseY)){
          if(child.click()){ 
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  public boolean addChild(AbstractUI child){
    child.setParent(this);
    return children.add(child);
  }
  public void addChilds(AbstractUI... childs){
    for(AbstractUI child : childs){
      addChild(child);
    }
  }
  public boolean removeChild(AbstractUI child){ return children.remove(child); }
  
  public void setRectMode(int mode){ if(mode == CORNER || mode == CENTER || mode == RADIUS) rectMode = mode; }
  
  protected float[] referencePos(){
    Rect absolute = absoluteRect();
    float[] refPos;
    
    if(rectMode == CENTER || rectMode == RADIUS) refPos = new float[]{rect.x+rect.w/2, rect.y+rect.h/2};
    else refPos = new float[]{rect.x, rect.y};
    
    return refPos;
  }
}

abstract class TextBasedUI extends AbstractUI{
  private int alignX, alignY;
  private String text;
  private PFont font;
  private int textSize;
  private color textColor;
  
  protected TextBasedUI(Rect rect, String text){
    super(rect);
    this.text = text;
    
    alignX = CENTER; alignY = CENTER;
    font = null;
    textSize = 16;
  }
  
  public void draw(){
    super.draw();
    
    if(font != null) textFont(font);
    textSize(textSize);
    textAlign(alignX, alignY);
    fill(textColor);
    
    text(text, rect.x, rect.y, rect.w, rect.h);    
  }
  
  public void setTextAlign(int alignX){
    setTextAlign(alignX, CENTER);
  }
  public void setTextAlign(int alignX, int alignY){
    if(alignX == LEFT || alignX == CENTER || alignX == RIGHT) this.alignX = alignX;
    if(alignY == TOP || alignY == CENTER || alignY == BOTTOM) this.alignY = alignY;
  }
  public void setFont(PFont font){ this.font = font; }
  public void setFont(PFont font, int size){
    this.font = font;
    this.textSize = size;
  }
  public void setTextSize(int size){ this.textSize = size; }
  public void setTextColor(color c){ this.textColor = c; }
}

class Scene extends AbstractContainer{
  protected boolean initialized;
  
  public Scene(){
    super(new Rect(0, 0, width, height));
    initialized = false;
  }
}

class Canvas extends AbstractContainer{
  public Canvas(Rect rect){
    super(rect);
  }
}

class Label extends TextBasedUI{
  public Label(Rect rect, String text){
    super(rect, text);
  }
}

class Button extends TextBasedUI{
  final color BASE_UNPRESS_COLOR = color(220);
  final color BASE_PRESS_COLOR = color(245);
  
  private Action action;
  private color pressedBg;
  private color unpressedBg;
  
  public Button(Rect rect, String text, Action action){
    super(rect, text);
    this.action = action;
    unpressedBg = BASE_UNPRESS_COLOR;
    pressedBg = BASE_PRESS_COLOR;
    enableBackground();
    setStroke(2);
  }
  
  public void draw(){
    if(mousePressed && contains(mouseX, mouseY)){
      background = pressedBg;
    }else{
      background = unpressedBg;
    }
    
    super.draw();
  }
  
  public void setBackground(color bg){
    unpressedBg = bg;
  }
  public void setBackground(color pressed, color unpressed){
    pressedBg = pressed;
    unpressedBg = unpressed;
  }
  
  public boolean click(){
    action.act();
    return true;
  }
}

class MapContainer extends AbstractUI{
  private Map map;
  private float xOff, yOff, zoom;
  
  private boolean locked;
  private float xMouse, yMouse;
  
  public MapContainer(Rect rect, Map map){
    super(rect);
    
    this.map = map;
    xOff = yOff = 0.5;
    zoom = 2;
    
    locked = false;
    xMouse = yMouse = 0;
  }
  
  public void update(){
    print("update");
    if(mousePressed){
      print("press");
      if(!locked && contains(mouseX, mouseY)){
        print("locked");
        xMouse = mouseX;
        yMouse = mouseY;
        locked = true;
      }else if(locked){
        print("moving");
        xOff = (xMouse - mouseX)/zoom;
        yOff = (yMouse - mouseY)/zoom;
      }
    }else locked = false;
  }
  
  public void draw(){
    super.draw();
    pushMatrix();
    translate(rect.x, rect.y);
    
    map.draw(rect.w, rect.h, xOff, yOff, zoom);
    popMatrix();
  }
}

class SettingsEditor extends AbstractContainer{
  Settings settings;
  
  SettingsEditor(Rect rect, Settings settings){
    super(rect);
    this.settings = settings;
  }
  
  void update(){
    
  }
  
  void draw(){
    
  }
}