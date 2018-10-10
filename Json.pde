abstract class JsonValue{  
  public abstract Object getValue();
  public abstract String getName();
  public String print(){
    return getName()+":"+getValue().toString();
  }
}

class JsonInt extends JsonValue{
  private int value;
  private String name;
  public JsonInt(String s){
    String[] tmp = s.split(":");
    name = tmp[0];
    if(tmp[1].charAt(0) == '-') value = -int(tmp[1].substring(1,tmp[1].length()));
    else value=int(tmp[1]);
  }
  public JsonInt(String name, int i){
    this.name = name;
    this.value = i;
  }
  
  public Integer getValue(){ return value; }
  public String getName(){ return name; }
}
class JsonFloat extends JsonValue{
  private float value;
  private String name;
  public JsonFloat(String s){
    String[] tmp = s.split(":");
    name = tmp[0];
    if(tmp[1].charAt(0) == '-') value = -float(tmp[1].substring(1,tmp[1].length()));
    else value=float(tmp[1]);
  }
  public JsonFloat(String name, float f){
    this.name = name;
    this.value = f;
  }
  
  public Float getValue(){ return value; }
  public String getName(){ return name; }
}
class JsonBool extends JsonValue{
  private boolean value;
  private String name;
  public JsonBool(String s){
    String[] tmp = s.split(":");
    name = tmp[0];
    value=boolean(tmp[1]);
  }
  public JsonBool(String name, boolean b){
    this.name = name;
    this.value = b;
  }
  
  public Boolean getValue(){ return value; }
  public String getName(){ return name; }
}
class JsonString extends JsonValue{
  private String name, value;
  
  public JsonString(String s){
    String[] tmp = s.split(":",2);
    name = tmp[0];
    value = tmp[1].substring(1, tmp[1].length()-1);
  }
  public JsonString(String name, String s){
    this.name = name;
    this.value = s;
  }
  public String getName(){ return name; }
  public String getValue(){ return value; }
  public String print(){
    return getName()+":\""+getValue().toString()+'"';
  }
}

class JsonObject extends JsonValue{
  String name;
  List<JsonValue> attributes;
  
  public JsonObject(String s){
    String[] tmp = s.split(":", 2);
    name = tmp[0];
    try{
      attributes = getJsonValFromStr(tmp[1]);
    }catch(IOException e){
      Evolve_io.print(e);
      attributes = new ArrayList();
    }
  }
  public JsonObject(String name, JsonValue... attrs){
    this(name, Arrays.asList(attrs));
  }
  public JsonObject(String name, List<JsonValue> attrs){
    this.name = name;
    attributes = attrs;
  }
  private List<JsonValue> getJsonValFromStr(String s) throws IOException{
    List<JsonValue> values = new ArrayList();
    int index=1  ;
    
    while(index < s.length()){
      int pairs=0;
      StringBuffer buf = new StringBuffer();
      String value = null;
      
      while(value==null && index<s.length()){
        char c = s.charAt(index);
        if(c=='{') pairs+=1;
        else if(c=='}') pairs-=1;
        
        if(c==',' && pairs == 0) value=buf.toString();
        else if(pairs<0){
          if(index == s.length()-1) value=buf.toString();
          else throw new IOException("Failed to parse JsonObject: found too much '}'");
        }
        else buf.append(s.charAt(index));
        ++index;
      }
      
      if(value == null) throw new IOException("Failed to parse JsonValue, aborting");
      else{
        //Evolve_io.print(value);
        char firstChar = value.charAt(value.indexOf(':')+1);
        switch(firstChar){
          case '{': values.add(new JsonObject(value)); break;
          case '"': values.add(new JsonString(value)); break;
          case '+':
          case '-':
            int v = int(value.charAt(value.indexOf(':')+2))-48;
            if(v>=0 && v<10){
              if(value.contains(".")) values.add(new JsonFloat(value));
              else values.add(new JsonInt(value));
            }else throw new IOException("Unknown json type, first char = '"+firstChar+"'");
          case '0':
          case '1':
          case '2':
          case '3':
          case '4':
          case '5':
          case '6':
          case '7':
          case '8':
          case '9':
            if(value.contains(".")) values.add(new JsonFloat(value));
            else values.add(new JsonInt(value));
            break;
          case 't':
          case 'f':
            if(value.equals("true") || value.equals("false")){ 
              values.add(new JsonBool(value));
              break;
            }
          default: throw new IOException("Unknown json type, first char = '"+firstChar+"'");
        }
      }
    }
    
    return values;
  }
  
  public List<JsonValue> getValue(){ return attributes; }
  public JsonValue getValue(String name){
    for(JsonValue v : attributes){
      if(v.getName().equals(name)) return v;
    }
    return null;
  }
  public String getName(){ return name; }
  public String print(){
    StringBuffer buf = new StringBuffer();
    buf.append("{");
    String prefix = "";
    for(JsonValue v : attributes){
      buf.append(prefix+v.print());
      prefix = ",";
    }
    buf.append("}");
    
    return name+":"+buf.toString();
  }
}

public JsonObject parseJson(String path){
  String text = loadStrings(path)[0];
  text = text.replaceAll("\\s","");
  return new JsonObject(text);
}