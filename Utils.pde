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
class ObservableInt implements ObservableValue<Integer>{
  int value;
  
  public ObservableInt(int i){ value = i; }
  
  public Integer get(){ return value; }
  public void set(Integer i){ value = i; }
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

abstract static class Step<E extends Number>{
  public static Step<Integer> arythmeticInt(final int r){ return new Step(){
    public Integer step(Number base, boolean ascend){
      return ascend ? (int)base + r : (int)base - r;
    }};
  }
  public static Step<Float> arythmeticFloat(final float r){ return new Step(){
    public Float step(Number base, boolean ascend){
      return ascend ? (float)base + r : (float)base - r;
    }};
  }
  public abstract E step(E base, boolean ascend);
}

class Settings{
  public abstract class ValueSetting<E extends Number>{
    public abstract E getValue();
    public abstract ObservableValue<E> getObsValue();
    public abstract Vector2<E> getRange();
    public abstract Step<E> getStep();
  }
  
  private class IntSetting extends ValueSetting<Integer>{
    protected ObservableInt obsValue;
    protected Vector2<Integer> range;
    protected Step<Integer> step;
    
    public IntSetting(int i, Vector2<Integer> range, Step<Integer> step){
      this.obsValue = new ObservableInt(i);
      this.range = range;
      this.step = step;
    }
    
    public Integer getValue(){ return obsValue.get(); }
    public ObservableInt getObsValue(){ return obsValue; }
    public Vector2<Integer> getRange(){ return range; }
    public Step<Integer> getStep(){ return step; }
  }
  private class FloatSetting extends ValueSetting<Float>{
    protected ObservableFloat obsValue;
    protected Vector2<Float> range;
    protected Step<Float> step;
    
    public FloatSetting(float f, Vector2<Float> range, Step<Float> step){
      this.obsValue = new ObservableFloat(f);
      this.range = range;
      this.step = step;
    }
    
    public Float getValue(){ return obsValue.get(); }
    public ObservableFloat getObsValue(){ return obsValue; }
    public Vector2<Float> getRange(){ return range; }
    public Step<Float> getStep(){ return step; }
  }
  
  private HashMap<String, IntSetting> intMap;
  private HashMap<String, FloatSetting> floatMap;
  private HashMap<String, ObservableBool> boolMap;
  
  public Settings(){
    intMap = new HashMap<String, IntSetting>();
    floatMap = new HashMap<String, FloatSetting>();
    boolMap = new HashMap<String, ObservableBool>();
  }
  
  public void addInt(String k, int i){ intMap.put(k, new IntSetting(i, null, null)); }
  public void addInt(String k, int i, Vector2<Integer> range, Step<Integer> step){
    intMap.put(k, new IntSetting(i, range, step));
  }
  public void addFloat(String k, float f){ floatMap.put(k, new FloatSetting(f, null, null)); }
  public void addFloat(String k, float f, Vector2<Float> range, Step<Float> step){
    floatMap.put(k, new FloatSetting(f, range, step));
  }
  public void addBool(String k, boolean b){ boolMap.put(k, new ObservableBool(b)); }
  
  public boolean hasRange(String k){ 
    return intMap.containsKey(k) ? intMap.get(k).range != null : false || 
      floatMap.containsKey(k) ? floatMap.get(k).range != null : false; 
  }
  public Vector2<Integer> getIntRange(String k){ return intMap.get(k).range; }
  public Vector2<Float> getFloatRange(String k){ return floatMap.get(k).range; }
  
  public int getInt(String k){ return intMap.get(k) != null ? intMap.get(k).getValue() : 0; }
  public IntSetting getIntSetting(String k){ return intMap.get(k); }
  public String[] getIntKeys(){ return keySetToArray(intMap.keySet()); }
  public float getFloat(String k){ return floatMap.get(k) != null ? floatMap.get(k).getValue() : 0f; }
  public FloatSetting getFloatSetting(String k){ return floatMap.get(k); }
  public String[] getFloatKeys(){ return keySetToArray(floatMap.keySet()); }
  public boolean getBool(String k){ return boolMap.get(k) != null ? boolMap.get(k).get() : false; }
  public ObservableBool getObsBool(String k){ return boolMap.get(k); }
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