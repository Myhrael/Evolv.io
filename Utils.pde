import java.util.*;

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

interface ObservableValue<E>{
  public E get();
  public void set(E v);
}
class ObservableInt implements ObservableValue<Float>{
  Float value;
  
  public ObservableInt(int i){ value = (float)i; }
  
  public Float get(){ return value; }
  public void set(Float i){ value = (float)ceil(i); }
}
class ObservableFloat implements ObservableValue<Float>{
  Float value;
  
  public ObservableFloat(Float f){ value = f; }
  
  public Float get(){ return value; }
  public void set(Float f){ value = f; }
}
class ObservableBool implements ObservableValue<Boolean>{
  Boolean value;
  
  public ObservableBool(Boolean b){ value = b; }
  
  public Boolean get(){ return value; }
  public void set(Boolean b){ value = b; }
}

class Settings{
  private HashMap<String, ObservableInt> intMap;
  private HashMap<String, Vector2<Integer>> intRange;
  private HashMap<String, ObservableFloat> floatMap;
  private HashMap<String, Vector2<Float>> floatRange;
  private HashMap<String, ObservableBool> boolMap;
  
  public Settings(){
    intMap = new HashMap<String, ObservableInt>();
    intRange = new HashMap<String, Vector2<Integer>>();
    floatMap = new HashMap<String, ObservableFloat>();
    floatRange = new HashMap<String, Vector2<Float>>();
    boolMap = new HashMap<String, ObservableBool>();
  }
  
  public void addInt(String k, Integer i){ intMap.put(k, new ObservableInt(i)); }
  public void addInt(String k, Integer i, Integer min, Integer max){
    addInt(k, i);
    intRange.put(k, new Vector2<Integer>(min, max));
  }
  public void addFloat(String k, Float f){ floatMap.put(k, new ObservableFloat(f)); }
  public void addFloat(String k, Float f, Float min, Float max){
    addFloat(k, f);
    floatRange.put(k, new Vector2<Float>(min, max));
  }
  public void addBool(String k, Boolean b){ boolMap.put(k, new ObservableBool(b)); }
  
  public boolean hasRange(String k){ return intRange.containsKey(k) || floatRange.containsKey(k); }
  public Vector2<Integer> getIntRange(String k){ return intRange.get(k); }
  public Vector2<Float> getFloatRange(String k){ return floatRange.get(k); }
  
  public ObservableInt getInt(String k){ return intMap.get(k); }
  public String[] getIntKeys(){ return keySetToArray(intMap.keySet()); }
  public ObservableFloat getFloat(String k){ return floatMap.get(k); }
  public String[] getFloatKeys(){ return keySetToArray(floatMap.keySet()); }
  public ObservableBool getBool(String k){ return boolMap.get(k); }
  public String[] getBoolKeys(){ return keySetToArray(boolMap.keySet()); }
  
  public int count(){ return intMap.size() + floatMap.size() + boolMap.size(); }
  
  private String[] keySetToArray(Set<String> set){
    String[] array = new String[set.size()];
    
    int i=0;
    for(String s : set){
      array[i] = s;
      ++i;
    }
    
    return array;
  }
}

//mouse button status
enum mbs{UP, PRESSED, DOWN, RELEASED}