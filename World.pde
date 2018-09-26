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
  static final float STARTING_FOOD_RATIO = 1/4;
  static final int STARTING_FOOD_RANDOM = 10;
  static final int MIN_FOOD_GAIN_RANDOM = -2;
  static final float FOOD_LOSS_RATIO = 1/60;
  
  Climate climate;
  float foodAmount;
  float altitude;
  
  Tile(Climate climate){
    this.climate = climate;
    foodAmount = climate.maxFood * STARTING_FOOD_RATIO 
                  + random(-STARTING_FOOD_RANDOM, STARTING_FOOD_RANDOM);
  }
  
  void update(float year){
    updateFood(year);
  }
  
  /*
   * w: width in pixel of the tile
   * h: height in pixel of the tile
   */
  void _draw(float w, float h){
    rect(0, 0, w, h);
  }
  
  void updateFood(float year){
    if(climate.getTemperature(year) < climate.foodCriticalLowTemp){
      decreaseFood(climate.foodCriticalLowTemp - climate.getTemperature(year));
    }else if (climate.getTemperature(year) > climate.foodCriticalUpTemp){
      decreaseFood(climate.getTemperature(year) - climate.foodCriticalUpTemp);
    }else{
      increaseFood(min(climate.getTemperature(year) - climate.foodCriticalLowTemp, 
                        climate.foodCriticalUpTemp - climate.getTemperature(year)));
    }
  }
  
  void decreaseFood(float tempLoss){
    foodAmount -= FOOD_LOSS_RATIO*foodAmount*tempLoss;
    if(foodAmount < 0) foodAmount = 0;
  }
  
  void increaseFood(float tempGain){
    foodAmount += climate.foodGain + random(MIN_FOOD_GAIN_RANDOM, tempGain);
    if(foodAmount > climate.maxFood) foodAmount = climate.maxFood;
  }
}

class Map{
  int w, h;
  float[][] tiles;
  
  Map(int w, int h){
    this.w = w; this.h = h;
    tiles = new float[h][w];//tiles = new Tile[h][w];
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
  void draw(float w, float h, float xOff, float yOff, float zoom){
    pushMatrix();
    
    int tileSize = int(min(w/this.w, h/this.h) * zoom);
    int tileWidth, tileHeight;
    float nbrTileX = w/tileSize;
    float nbrTileY = h/tileSize;
    int usedWidth=0, usedHeight=0;
    
    for(int j=(int)yOff; j<=h && j<nbrTileY+(int)yOff; ++j){
      if(j == (int)yOff) tileHeight = int((1-(yOff-int(yOff))) * tileSize);
      else if(usedHeight+tileSize > h) tileHeight = int(h-usedHeight);
      else tileHeight = tileSize;
      
      pushMatrix();
      usedWidth = 0;
      
      for(int i=(int)xOff; i<=w && i<nbrTileX+(int)xOff; ++i){
        if(i == (int)xOff) tileWidth = int((1-(xOff-int(xOff))) * tileSize);
        else if(usedWidth+tileSize > w) tileWidth = int(w-usedWidth);
        else tileWidth = tileSize;
        
        if(i>=0 && j>=0){
          fill(map(tiles[j][i], 0, 1, 50, 255));
          //noStroke();
          stroke(1);
          rect(0, 0, tileWidth, tileHeight);
        }
        
        usedWidth += tileWidth;
        translate(tileWidth, 0);
      }
      
      popMatrix();
      usedHeight += tileHeight;
      translate(0, tileHeight);
    }
    
    popMatrix();
  }
}

enum Climate{FOREST(    150, 4,  5, 30, -10, 25, 2.0, 2.5,  0.1),
             GRASSLAND( 120, 3,  0, 30, -10, 35, 1.0, 0.5,  0.05),
             MOUNTAIN(  75,  2, -5, 25, -25, 15, 4.0, 1.25, 0.25),
             SWAMP(     100, 5,  5, 35,  -5, 20, 1.5, 1.0,  0.1),
             WATER(     120, 3,  2, 30,   0, 20, 1.0, 0.5,  0.05);

  final int maxFood, foodGain, foodCriticalLowTemp, foodCriticalUpTemp;
  final int temperatureMin, temperatureMax;
  final float expectedDamage, damageVariance, damageProbability;
  
  private Climate(int maxFood, int foodGain, int foodCriticalLowTemp, int foodCriticalUpTemp, 
                  int temperatureMin, int temperatureMax, float expectedDamage,
                  float damageVariance, float damageProbability){
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