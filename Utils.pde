import java.util.*;

class Pair<U, V>{
  public U p1;
  public V p2;
  
  public Pair(U p1, V p2){
    this.p1 = p1;
    this.p2 = p2;
  }
}
class NameValuePair<V> extends Pair<String, V>{
  public NameValuePair(String name, V value){
    super(name, value);
  }
  
  public String getName(){ return p1; }
  public V getValue(){ return p2; }
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
  public static Step<Integer> geometricInt(final int p){ return new Step(){
    public Integer step(Number base, boolean ascend){
      return ascend ? (int)base*p : (int)base/p;
    }};
  }
  public static Step<Float> arythmeticFloat(final float r){ return new Step(){
    public Float step(Number base, boolean ascend){
      return ascend ? (float)base + r : (float)base - r;
    }};
  }
  public abstract E step(E base, boolean ascend);
}

public interface Range<N extends Number>{
  public N min();
  public N max();
  
  public boolean contains(N n);
}

public class IntRange implements Range<Integer>{
  private Vector2<ObservableInt> values;
  
  public IntRange(ObservableInt v1, ObservableValue v2){
    values = new Vector2(v1, v2);
  }
  public IntRange(int i1, int i2){
    this(new ObservableInt(i1), new ObservableInt(i2));
  }
  
  public Integer min(){ return values.e1.get(); }
  public Integer max(){ return values.e2.get(); }
  public boolean contains(Integer i){
    return i>=min() && i<=max();
  }
}
public class FloatRange implements Range<Float>{
  private Vector2<ObservableFloat> values;
  
  public FloatRange(ObservableFloat v1, ObservableFloat v2){
    values = new Vector2(v1, v2);
  }
  public FloatRange(float f1, float f2){
    this(new ObservableFloat(f1), new ObservableFloat(f2));
  }
  
  public Float min(){ return values.e1.get(); }
  public Float max(){ return values.e2.get(); }
  public boolean contains(Float f){
    return f>=min() && f<=max();
  }
}

//mouse button status
enum mbs{UP, PRESSED, DOWN, RELEASED}