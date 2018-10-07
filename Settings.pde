class Settings{
  private HashMap<String, IntSetting> intMap;
  private HashMap<String, FloatSetting> floatMap;
  private HashMap<String, BoolSetting> boolMap;
  
  public Settings(){
    intMap = new HashMap<String, IntSetting>();
    floatMap = new HashMap<String, FloatSetting>();
    boolMap = new HashMap<String, BoolSetting>();
  }
  
  public void addInt(String k, int i){ intMap.put(k, new IntSetting(i, null, null)); }
  public void addInt(String k, int i, IntRange range, Step<Integer> step){
    intMap.put(k, new IntSetting(i, range, step));
  }
  public void addFloat(String k, float f){ floatMap.put(k, new FloatSetting(f, null, null)); }
  public void addFloat(String k, float f, FloatRange range, Step<Float> step){
    floatMap.put(k, new FloatSetting(f, range, step));
  }
  public void addBool(String k, boolean b){ boolMap.put(k, new BoolSetting(b)); }
  
  public boolean hasRange(String k){ 
    return intMap.containsKey(k) ? intMap.get(k).range != null : false || 
      floatMap.containsKey(k) ? floatMap.get(k).range != null : false; 
  }
  public IntRange getIntRange(String k){ return intMap.get(k).range; }
  public FloatRange getFloatRange(String k){ return floatMap.get(k).range; }
  public void setIntRange(String k, IntRange range, Step<Integer> step){ 
    IntSetting s = intMap.get(k);
    s.range = range; 
    s.step = step;
  }
  public void setFloatRange(String k, FloatRange range, Step<Float> step){ 
    FloatSetting s = floatMap.get(k);
    s.range = range; 
    s.step = step;
  }
  
  public int getInt(String k){ return intMap.get(k) != null ? intMap.get(k).getValue() : 0; }
  public IntSetting getIntSetting(String k){ return intMap.get(k); }
  public String[] getIntKeys(){ return keySetToArray(intMap.keySet()); }
  public float getFloat(String k){ return floatMap.get(k) != null ? floatMap.get(k).getValue() : 0f; }
  public FloatSetting getFloatSetting(String k){ return floatMap.get(k); }
  public String[] getFloatKeys(){ return keySetToArray(floatMap.keySet()); }
  public boolean getBool(String k){ return boolMap.get(k) != null ? boolMap.get(k).getValue() : false; }
  public ObservableBool getObsBool(String k){ return boolMap.get(k) != null ? boolMap.get(k).getObsValue() : null; }
  public String[] getBoolKeys(){ return keySetToArray(boolMap.keySet()); }
  
  public boolean hasChanged(){
    for(String s : getIntKeys()){
      if(intMap.get(s).hasChanged()) return true;
    }
    for(String s : getFloatKeys()){
      if(floatMap.get(s).hasChanged()) return true;
    }
    for(String s : getBoolKeys()){
      if(boolMap.get(s).hasChanged()) return true;
    }
    
    return false;
  }
  
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

public abstract class ValueSetting<E>{
  public abstract E getValue();
  public abstract ObservableValue<E> getObsValue();
  public abstract boolean hasChanged();
}
public abstract class NumberSetting<E extends Number> extends ValueSetting<E>{
  public abstract Range getRange();
  public abstract Step<E> getStep();
}

public class IntSetting extends NumberSetting<Integer>{
  protected ObservableInt obsValue;
  protected IntRange range;
  protected Step<Integer> step;
  private int previous;
  
  public IntSetting(int i, IntRange range, Step<Integer> step){
    this.obsValue = new ObservableInt(i);
    this.range = range;
    this.step = step;
  }
  
  public Integer getValue(){ return obsValue.get(); }
  public ObservableInt getObsValue(){ return obsValue; }
  public IntRange getRange(){ return range; }
  public Step<Integer> getStep(){ return step; }
  public boolean hasChanged(){
    boolean changed = previous != obsValue.get();
    if(changed){
      previous = obsValue.get();
      return true;
    }else return false;
  }
}
public class FloatSetting extends NumberSetting<Float>{
  protected ObservableFloat obsValue;
  protected FloatRange range;
  protected Step<Float> step;
  private float previous;
  
  public FloatSetting(float f, FloatRange range, Step<Float> step){
    this.obsValue = new ObservableFloat(f);
    this.range = range;
    this.step = step;
  }
  
  public Float getValue(){ return obsValue.get(); }
  public ObservableFloat getObsValue(){ return obsValue; }
  public FloatRange getRange(){ return range; }
  public Step<Float> getStep(){ return step; }
  public boolean hasChanged(){
    boolean changed = previous != obsValue.get();
    if(changed){
      previous = obsValue.get();
      return true;
    }else return false;
  }
}
public class BoolSetting extends ValueSetting<Boolean>{
  protected ObservableBool obsValue;
  private boolean previous;
  
  public BoolSetting(boolean b){
    obsValue = new ObservableBool(b);
  }
  
  public boolean hasChanged(){
    boolean changed = previous != obsValue.get();
    if(changed){
      previous = obsValue.get();
      return true;
    }else return false;
  }
  public Boolean getValue(){ return obsValue.get(); }
  public ObservableBool getObsValue(){ return obsValue; }
}