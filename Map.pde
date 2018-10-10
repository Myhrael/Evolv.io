class Tile{
  private static final float STARTING_FOOD_RATIO = 1/4;
  private static final int STARTING_FOOD_RANDOM = 10;
  private static final int MIN_FOOD_GAIN_RANDOM = -2;
  private static final float FOOD_LOSS_RATIO = 1/60;
  
  private Climate climate;
  private float foodAmount;
  private float altitude;
  private int x, y;
  
  Tile(int x, int y){
    this(0, x, y);
  }
  Tile(float altitude, int x, int y){
    this(null, altitude, x, y);
  }
  Tile(Climate climate, float altitude, int x, int y){
    this.climate = climate;
    foodAmount = climate == null ? 0 : climate.maxFood * STARTING_FOOD_RATIO 
      + random(-STARTING_FOOD_RANDOM, STARTING_FOOD_RANDOM);
    this.altitude = altitude;
    this.x = x; this.y = y;
  }
  
  void update(float year){
    updateFood(year);
  }
  
  /*
   * w: width in pixel of the tile
   * h: height in pixel of the tile
   * hueOnly: set color depending only on the hue (widht preset saturation && brightness)
   */
  void draw(int w, int h, boolean hueOnly){
    noStroke();
    
    int hue = climate == null ? 1 : climate.hue;
    int sat = climate == null ? 0 : hueOnly ? 100 : (int)map(foodAmount, 0, climate.maxFood, 0, 99);
    int brt = (int) map(altitude, -10, 20, 20, 90);
     
    colorMode(HSB, 360, 100, 100);
    fill(hue, sat, brt);
    
    rect(0, 0, w, h);
  }
  
  public void setClimate(Climate c){
    this.climate = c;
    if(this.foodAmount == 0) this.foodAmount = c.maxFood * STARTING_FOOD_RATIO 
      + random(-STARTING_FOOD_RANDOM, STARTING_FOOD_RANDOM);
  }
  
  private void updateFood(float year){
    if(climate.getTemperature(year) < climate.foodCriticalLowTemp){
      decreaseFood(climate.foodCriticalLowTemp - climate.getTemperature(year));
    }else if (climate.getTemperature(year) > climate.foodCriticalUpTemp){
      decreaseFood(climate.getTemperature(year) - climate.foodCriticalUpTemp);
    }else{
      increaseFood(min(climate.getTemperature(year) - climate.foodCriticalLowTemp, 
                        climate.foodCriticalUpTemp - climate.getTemperature(year)));
    }
  }
  
  private void decreaseFood(float tempLoss){
    foodAmount -= FOOD_LOSS_RATIO*foodAmount*tempLoss;
    if(foodAmount < 0) foodAmount = 0;
  }
  
  private void increaseFood(float tempGain){
    foodAmount += climate.foodGain + random(MIN_FOOD_GAIN_RANDOM, tempGain);
    if(foodAmount > climate.maxFood) foodAmount = climate.maxFood;
  }
}

class Map{
  int w, h;
  Tile[][] tiles;
  boolean hueOnly;
  
  Map(JsonObject json){
    JsonObject dim = (JsonObject) json.getValue("dim");
    w = (int) dim.getValue("width").getValue();
    h = (int) dim.getValue("height").getValue();
    tiles = new Tile[h][w];
    load((JsonObject) json.getValue("tiles"));
  }
  Map(int w, int h){ this(w, h, false); }
  Map(int w, int h, boolean hueOnly){
    this.w = w; this.h = h;
    tiles = new Tile[h][w];
    this.hueOnly = hueOnly;
  }
  
  void update(){
    
  }
  
  /*
   * w: width in pixel taken by the map
   * h: height in pixel taken by the map
   * xOff: x offset
   * yOff: y offset
   * rotation: rotation
   * zoom: zoom of the map
   */
  public void draw(float w, float h, float xOff, float yOff, float zoom){    
    int tileSize = int(min(w/this.w, h/this.h) * zoom);
    int tileWidth, tileHeight;
    float usedWidth = 0, usedHeight = 0;
    
    pushMatrix();
    
    for(int j=floor(yOff); j<this.h && usedHeight<h; ++j){
      if(j == floor(yOff) && yOff != int(yOff)) tileHeight = yOff>=0 ? int((1-yOff%1) * tileSize) : int((-yOff)%1 * tileSize);
      else if(usedHeight+tileSize>h) tileHeight = int(h-usedHeight);
      else tileHeight = tileSize;
      
      pushMatrix();
      
      for(int i=floor(xOff); i<this.w && usedWidth<w; ++i){
        if(i == floor(xOff) && xOff != int(xOff)) tileWidth = xOff>=0 ? int((1-xOff%1) * tileSize) : int((-xOff)%1 * tileSize);
        else if(usedWidth+tileSize>w) tileWidth = int(w-usedWidth);
        else tileWidth = tileSize;
        
        if(j>=0 && i>=0){
          tiles[j][i].draw(tileWidth, tileHeight, hueOnly);
        }
        
        usedWidth += tileWidth;
        translate(tileWidth, 0);
      }
      
      popMatrix();
      usedWidth = 0;
      usedHeight += tileHeight;
      translate(0, tileHeight);
    }
    
    popMatrix();
  }
  
  public void set(Tile[][] newMap, int w, int h){
    tiles = newMap;
    this.w = w;
    this.h = h;
  }
  
  public void load(JsonObject jsonTiles){
    List<JsonValue> values = jsonTiles.getValue();
    
    for(int j=0; j<h; ++j){
      for(int i=0; i<w; ++i){
        JsonObject jsonTile = (JsonObject) values.get(j*w+i);
        
        String climateString = (String) jsonTile.getValue("climate").getValue();
        float altitude = (float) jsonTile.getValue("altitude").getValue();
        Climate climate;
        if(climateString.equals("WATER")) climate = Climate.WATER;
        else if(climateString.equals("MOUNTAIN")) climate = Climate.MOUNTAIN;
        else if(climateString.equals("GRASSLAND")) climate = Climate.GRASSLAND;
        else if(climateString.equals("FOREST")) climate = Climate.FOREST;
        else climate = Climate.SWAMP;
        
        tiles[j][i] = new Tile(climate, altitude, i, j);
      }
    }
  }
  
  public void save(){
    String path = "/data/map/";
    String name = "map";
    String[] usedNamesArray = listFileNames(sketchPath()+path);
    int index = 1;
    
    if(usedNamesArray != null){
      List<String> usedNames = Arrays.asList(usedNamesArray);
      while(usedNames.contains(name+index+".txt")) ++index;
    }
      
    save(name+index, path);
  }
  public void save(String name, String path){
    JsonObject infos = saveMapInfos();
    JsonObject tiles = saveTiles();
    saveStrings(path+name+".txt", new String[]{new JsonObject(name, infos, tiles).print()});
  }
  private String[] listFileNames(String dir) {
    File file = new File(dir);
    if (file.isDirectory()) {
      String names[] = file.list();
      return names;
    } else {
      // If it's not a directory
      return null;
    }
  }
  private JsonObject saveMapInfos(){
    ArrayList<JsonValue> dim = new ArrayList();
    dim.add(new JsonInt("width", w));
    dim.add(new JsonInt("height", h));
    JsonObject infos = new JsonObject("dim", dim);
    
    return infos;
  }
  private JsonObject saveTiles(){
    ArrayList<JsonValue> jsonTiles = new ArrayList();
    for(int j=0; j<h; ++j){
      for(int i=0; i<w; ++i){
        Tile tile = tiles[j][i];
        ArrayList<JsonValue> attributes = new ArrayList();
        attributes.add(new JsonString("climate", tile.climate.toString()));
        attributes.add(new JsonFloat("altitude", tile.altitude));
        
        jsonTiles.add(new JsonObject("tile"+(j*w+i), attributes));
      }
    }
    return new JsonObject("tiles", jsonTiles);
  }
}

public boolean tileHasClimateInRange(Tile[][] tiles, int x, int y, int w, int h, int range, Climate climate){
  for(int j=y-range; j<h && j<=y+range; ++j){
    if(j>=0){
      for(int i=x-range; i<w && i<=x+range; ++i){
        if(i>=0 && tiles[j][i].climate == climate) return true;
      }
    }
  }
  
  return false;
}