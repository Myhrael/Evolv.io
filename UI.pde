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
    stroke = -1;
  }
  
  public void draw(){
    if(stroke == -1) noStroke();
    else stroke(stroke);
    
    if(bgEnabled){
      fill(background);
      rect(rect.x, rect.y, rect.w, rect.h);
    }
  }
  public void update(){ }
  public boolean click(){ 
    if(isEnabled() && contains(mouseX, mouseY)){ 
      onFocus = this;
      return true;
    } else return false; 
  }
  
  public boolean onFocus(){ return onFocus == this; }
  public void enable(){ enabled = true; }
  public void disable(){ enabled = false; }
  public boolean isEnabled(){ return enabled; }
  public void setVisible(boolean visible){ 
    this.visible = visible;
    if(!visible) this.disable();
  }
  public boolean isVisible(){ return visible; }
  
  public void setBackground(color c){ background = c; }
  public void enableBackground(){ bgEnabled = true; }
  public void enableBackground(boolean b){ bgEnabled = b; }
  
  public void setStroke(color c){ stroke = c; }
  
  public AbstractContainer getParent(){ return parent; }
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
        pushMatrix();
        child.draw();
        popMatrix();
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
    float[] refPos = new float[]{absolute.x, absolute.y};
    
    if(rectMode == CENTER || rectMode == RADIUS){
      refPos[0] += rect.w/2;
      refPos[1] += rect.h/2;
    }
    
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
  
  public void update(){ if(onFocus() && mStatus == mbs.PRESSED) action.act(); }
  
  public void setBackground(color bg){
    unpressedBg = bg;
  }
  public void setBackground(color pressed, color unpressed){
    pressedBg = pressed;
    unpressedBg = unpressed;
  }
}

abstract class Control extends AbstractUI{
  protected ObservableValue value;
  
  public Control(Rect rect, ObservableValue v){
    super(rect);
    value = v;
  }
}

class CheckBox extends Control{
  private static final int BOX_SIZE = 15;
  private Label label;
  
  public CheckBox(Rect rect, ObservableValue<Boolean> value, String text){
    this(rect, value, text, value.get());
  }
  public CheckBox(Rect rect, ObservableValue<Boolean> value, String text, boolean checked){
    super(rect, value);
    value.set(checked);
    label = new Label(new Rect(0, 0, 2*rect.w/3, rect.h), text);
    label.setTextAlign(LEFT);
  }
  
  public void update(){
    super.update();
    if(mStatus == mbs.PRESSED && contains(mouseX, mouseY)){
      value.set(!(boolean)value.get());
    }
  }
  
  public void draw(){
    super.draw();
    translate(rect.x, rect.y);
    drawCheckedBox();
    translate(rect.w/3, 0);
    label.draw();
  }
  
  private void drawCheckedBox(){
    pushMatrix();
    stroke(150);
    fill(230);
    translate(rect.w/6-BOX_SIZE, rect.h/2-BOX_SIZE);
    rect(0, 0, BOX_SIZE, BOX_SIZE);
    if((boolean) value.get()){
      line(1, 1, BOX_SIZE-1, BOX_SIZE-1);
      line(1, BOX_SIZE-1, BOX_SIZE-1, 1);
    }
    popMatrix();
  }
  
  public boolean isChecked(){ return (boolean) value.get(); }
}

class Slider extends Control{
  private static final int MARGIN = 10;
  
  private float min, max;
  private float step;
  private color lineColor, cursorColor;
  
  public Slider(Rect rect, ObservableInt value, Vector2<Integer> range){
    this(rect, value, range.e1, range.e2, 1);
  }
  public Slider(Rect rect, ObservableFloat value, Vector2<Float> range, float step){
    this(rect, value, range.e1, range.e2, step);
  }
  private Slider(Rect rect, ObservableValue value, float min, float max, float step){
    super(rect, value);
    this.min = min; this.max = max;
    this.step = step;
    lineColor = color(20);
    cursorColor = color(80);
  }
  
  public void update(){
    super.update();
    if(onFocus() && mousePressed){
      Rect absolute = absoluteRect();
      float v = map(mouseX, absolute.x+MARGIN, absolute.x+rect.w-MARGIN, min, max);
      v -= v%step;
      v = v<min ? min : v>max ? max : v;
      value.set(v);
      print((float)value.get()+"    ");
    }
  }
  
  public void draw(){
    super.draw();
    pushMatrix();
    
    strokeWeight(min(10, 2*rect.h/3));
    stroke(lineColor);
    line(rect.x+MARGIN, rect.y+rect.h/2, rect.x+rect.w-MARGIN, rect.y+rect.h/2);
    
    strokeWeight(1);
    stroke(0);
    rectMode(CENTER);
    fill(cursorColor);
    float cursorWidth = min(15, rect.w/4);
    float v = (float) value.get();
    float pos = map(v, min, max, rect.x+MARGIN+cursorWidth/2, rect.x+rect.w-MARGIN);
    translate(pos, rect.y+rect.h/2);
    rect(0, 0, min(15, rect.w/4),rect.h/2);
    
    popMatrix();
  }
}

class MapContainer extends AbstractUI{  
  private Map map;
  private float xOff, yOff, zoom;
  
  private boolean locked;
  private float xMouse, yMouse, refX, refY;
  
  public MapContainer(Rect rect, Map map){
    super(rect);
    
    this.map = map;
    xOff = 0; yOff = 0;
    refX = refY = 0;
    zoom = 1;
    
    locked = false;
    xMouse = yMouse = 0;
  }
  
  public void draw(){
    super.draw();
    pushMatrix();
    translate(rect.x, rect.y);
    
    updateOffsets();
    map.draw(rect.w, rect.h, this.xOff, this.yOff, this.zoom);
    
    popMatrix();
  }
  
  private void updateOffsets(){
    if(mStatus == mbs.RELEASED){
      locked = false;
    }
    
    if(locked){
      this.xOff = refX + dragX();
      this.yOff = refY + dragY();
    }
    
    if(mStatus == mbs.PRESSED && contains(mouseX, mouseY)){
      locked = true;
      refX = xOff;
      refY = yOff;
      xMouse = mouseX; yMouse = mouseY;
    }    
  }
  private float dragX(){ return 2*(xMouse - mouseX)*(map.w)/(zoom*width); }
  private float dragY(){ return 2*(yMouse - mouseY)*(map.h)/(zoom*height); }
}

class SettingsEditor extends AbstractContainer{
  Settings settings;
  
  SettingsEditor(Rect rect, Settings settings){
    super(rect);
    this.settings = settings;
    addSettings();
  }
  
  private void addSettings(){
    float elHeight = rect.h/settings.count();
    int el = 0;
    
    for(String k : settings.getIntKeys()){
      if(settings.hasRange(k)){
        Vector2<Integer> range = settings.getIntRange(k);
        Canvas c = new Canvas(new Rect(0, el * elHeight, rect.w, elHeight));
        c.addChild(new Label(new Rect(0, 0, rect.w/3, elHeight), k));
        c.addChild(new Slider(new Rect(rect.w/3, 0, 2*rect.w/3, elHeight), settings.getInt(k), range));
        addChild(c);
        ++el;
      }
    }
    for(String k : settings.getFloatKeys()){
      if(settings.hasRange(k)){
        Vector2<Float> range = settings.getFloatRange(k);
        Canvas c = new Canvas(new Rect(0, el * elHeight, rect.w, elHeight));
        c.addChild(new Label(new Rect(0, 0, rect.w/3, elHeight), k));
        c.addChild(new Slider(new Rect(rect.w/3, 0, 2*rect.w/3, elHeight), settings.getFloat(k), range, 0.1));
        addChild(c);
        ++el;
      }
    }
    for(String k : settings.getBoolKeys()){
      addChild(new CheckBox(new Rect(0, el*elHeight, rect.w, elHeight), settings.getBool(k), k));
      ++el;
    }
  }
}