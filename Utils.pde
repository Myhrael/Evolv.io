interface Action{
  public void act();
}

class ChangeSceneAction implements Action{
  private Scene scene;
  
  public ChangeSceneAction(Scene scene){
    this.scene = scene;
  }
  
  public void act(){ activeScene = scene; }
}

class Rect{
  public float x, y, w, h;
  
  public Rect(float x, float y, float w, float h){
    this.x = x; this.y = y; this.w = w; this.h = h;
  }
  
  public boolean contains(float x, float y){ 
    return x>=this.x && x<= this.x+this.w && y>=this.y && y<=this.y+this.h;
  }    
}

class Vector2<E>{
  E e1;
  E e2;
  
  public Vector2(E e1, E e2){
    this.e1 = e1;
    this.e2 = e2;
  }
}

class Settings{
  private HashMap<String, Integer> intMap;
  private HashMap<String, Vector2<Integer>> intRange;
  private HashMap<String, Float> floatMap;
  private HashMap<String, Vector2<Float>> floatRange;
  private HashMap<String, Boolean> boolMap;
  
  public Settings(){
    intMap = new HashMap<String, Integer>();
    floatMap = new HashMap<String, Float>();
    boolMap = new HashMap<String, Boolean>();
  }
  
  public void add(String k, Integer i){ intMap.put(k, i); }
  public void add(String k, Float f){ floatMap.put(k, f); }
  public void add(String k, Boolean b){ boolMap.put(k, b); }
  
  public int getInt(String k){ return intMap.get(k); }
  public float getFloat(String k){ return floatMap.get(k); }
  public boolean getBool(String k){ return boolMap.get(k); }
}