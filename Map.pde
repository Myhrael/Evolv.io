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