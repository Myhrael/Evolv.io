import g4p_controls.*;

float maxFPS = 30;
float lastDrawTime = 0;
Scene main, game, editor;
Scene activeScene;
AbstractUI onFocus;

mbs mStatus = mbs.UP;
float mw = 0;//mouse wheel count

void setup() {
  //noLoop();
  fullScreen();
  //size(800, 600);
  //colorMode(HSB,1.0);
  main = new MainScene();
  editor = new EditorScene();
  
  activeScene = main;
}

void draw(){
  background(255);
  
  activeScene.update();
  
  if(millis() - lastDrawTime > maxFPS/1000){  // Limit fps
    activeScene.draw();
    lastDrawTime = millis();
  }
  
  updateMouseBtnStatus();
}

void mousePressed(){
  mStatus = mbs.PRESSED;
  activeScene.click();
}
void mouseReleased(){
  mStatus = mbs.RELEASED;
}
void mouseWheel(MouseEvent e){
  mw = e.getCount();
}

void updateMouseBtnStatus(){
  if(mStatus == mbs.PRESSED) mStatus = mbs.DOWN;
  else if(mStatus == mbs.RELEASED) mStatus = mbs.UP;
  
  mw=0;
}

class MainScene extends Scene{
  public void update(){
    if(!initialized) {
      this.buildUI();
      initialized = true;
    }
    super.update();
  }
  
  private void buildUI(){
    final float buttonWidth = rect.w/5;
    final float buttonHeight = rect.h/10;
    
    Label title = new Label(new Rect(0, 0, rect.w, rect.h/4), "EVOLV.IO");
    title.setTextSize(40);
    
    Canvas buttons = new Canvas(new Rect(rect.w/4, rect.h/4, rect.w/2, 5*rect.h/8));
    buttons.setRectMode(CENTER);
    
    Button playBtn = new Button(new Rect(0, -1.5*buttonHeight, buttonWidth, buttonHeight), "Play", new NewGameAction("map1"));
    Button editorBtn = new Button(new Rect(0, 0, buttonWidth, buttonHeight), "Create World", new ChangeSceneAction(editor));
    Button quitBtn = new Button(new Rect(0, +1.5*buttonHeight, buttonWidth, buttonHeight), "Quit", new Action(){ public void act(){ exit(); } });
    
    buttons.addChilds(playBtn, editorBtn, quitBtn);
    
    this.addChilds(title, buttons);
  }
}

class GameScene extends Scene{  
  World world;
  Settings worldSettings;
  
  public GameScene(Map map){
    world = new World(map);
    worldSettings = new WorldSettings();
  }
  
  public void update(){
    if(!initialized) {
      this.buildUI();
      initialized = true;
    }
    world.update();
    super.update();
  }
  
  private void buildUI(){
    MapContainer mapContainer = new MapContainer(new Rect(0, 0, rect.w, rect.h), world.map);
    
    
    this.addChild(mapContainer);
  }
}

class EditorScene extends Scene{
  private MapSettings mapSettings;
  private MapGenerator mapGenerator;
  
  public EditorScene(){
    mapSettings = new MapSettings();
    mapGenerator = new MapGenerator(mapSettings);
  }
  
  public void update(){
    if(!initialized) {
      this.buildUI();
      initialized = true;
    }
    mapGenerator.update();
    super.update();
  }
  
  private void buildUI(){
    Label title = new Label(new Rect(0, 0, rect.w, rect.h/5), "Editor");
    title.setTextSize(40);
    
    MapContainer mapContainer = new MapContainer(new Rect(0, rect.h/5, 2*rect.w/3, 4*rect.h/5), mapGenerator.map);
    mapContainer.setBackground(color(220));
    mapContainer.setStroke(1);
    mapContainer.enableBackground();
    
    SettingsEditor settingsEditor = new SettingsEditor(new Rect(2*rect.w/3, rect.h/5, rect.w/3, 3*rect.h/5), mapSettings);
    settingsEditor.setBackground(color(120));
    settingsEditor.enableBackground();
    
    Canvas btns = new Canvas(new Rect(2*rect.w/3, 4*rect.h/5, rect.w/3, rect.h/5));
    btns.addChild(new Button(new Rect(0, 0, btns.rect.w/2, btns.rect.h/2), "Gen. climate seeds", new Action(){ public void act(){ mapGenerator.putClimateSeeds(mapGenerator.tileBlobs, mapGenerator.map.tiles); }}));
    btns.addChild(new Button(new Rect(btns.rect.w/2, 0, btns.rect.w/2, btns.rect.h/2), "Exp. climates", new Action(){ public void act(){ mapGenerator.generateClimates(mapGenerator.tileBlobs, mapGenerator.map.tiles); }}));
    btns.addChild(new Button(new Rect(0, btns.rect.h/2, btns.rect.w/2, btns.rect.h/2), "Save", new Action(){ public void act(){ mapGenerator.map.save(); }}));
    btns.addChild(new Button(new Rect(btns.rect.w/2, btns.rect.h/2, btns.rect.w/2, btns.rect.h/2), "Quit", new ChangeSceneAction(main)));
    this.addChilds(title, mapContainer, settingsEditor, btns);
  }
}