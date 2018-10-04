public class World{
  
  float cameraX, cameraY, cameraZoom;
  boolean draggedFar = false;
  
  float timeStep = 0.002;
  int playSpeed = 1;
  float year = 0;
  
  ArrayList<Creature> creatures;
  Map map;
  
  World(Map map){
    resetZoom();
    
    this.map = map;
    generateTiles();
  }
  
  void update(int playSpeed, float timeStep){
    //Input
    if (dist(pmouseX, pmouseY, mouseX, mouseY) > 5) {
      draggedFar = true;
    }
    
    //Update
    for (int iteration = 0; iteration < playSpeed; iteration++) {
      iterate(timeStep);
    }
  }
  
  void generateTiles(){
    
  }
  
  void iterate(float timeStep){
    
  }
  
  void resetZoom(){/*
    cameraX = rect.w*0.5;
    cameraY = rect.h*0.5;
    cameraZoom = 1;*/
  }
}

class Tile{
  private static final float STARTING_FOOD_RATIO = 1/4;
  private static final int STARTING_FOOD_RANDOM = 10;
  private static final int MIN_FOOD_GAIN_RANDOM = -2;
  private static final float FOOD_LOSS_RATIO = 1/60;
  
  private Climate climate;
  private float foodAmount;
  private float altitude;
  
  Tile(float altitude){
    this(null, altitude);
  }
  Tile(Climate climate, float altitude){
    this.climate = climate;
    foodAmount = climate == null ? 0 : climate.maxFood * STARTING_FOOD_RATIO 
      + random(-STARTING_FOOD_RANDOM, STARTING_FOOD_RANDOM);
    this.altitude = altitude;
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
  
  public void setClimate(Climate climate){ 
    this.climate = climate;
    if(this.foodAmount == 0) this.foodAmount = climate.maxFood * STARTING_FOOD_RATIO 
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
}

enum Climate{FOREST(    135, 150, 4,  5, 30, -10, 25, 2.0, 2.5,  0.1),
             GRASSLAND(  75, 120, 3,  0, 30, -10, 35, 1.0, 0.5,  0.05),
             MOUNTAIN(  30, 75,  2, -5, 25, -25, 15, 4.0, 1.25, 0.25),
             SWAMP(     270, 100, 5,  5, 35,  -5, 20, 1.5, 1.0,  0.1),
             WATER(     240, 120, 3,  2, 30,   0, 20, 1.0, 0.5,  0.05);
  
  final int hue;
  final int maxFood, foodGain, foodCriticalLowTemp, foodCriticalUpTemp;
  final int temperatureMin, temperatureMax;
  final float expectedDamage, damageVariance, damageProbability;
  
  private Climate(int hue, int maxFood, int foodGain, int foodCriticalLowTemp, int foodCriticalUpTemp, 
                  int temperatureMin, int temperatureMax, float expectedDamage,
                  float damageVariance, float damageProbability){
            this.hue = hue;
            this.maxFood = maxFood; this.foodCriticalUpTemp = foodCriticalUpTemp;
            this.foodCriticalLowTemp = foodCriticalLowTemp; this.foodGain = foodGain;
            this.temperatureMin = temperatureMin; this.temperatureMax = temperatureMax;
            this.expectedDamage = expectedDamage; this.damageVariance = damageVariance;
            this.damageProbability = damageProbability;
  }
  
  public float getTemperature(float year){
    return map(-sin(year*2*PI), -1, 1, temperatureMin, temperatureMax);
  }
}