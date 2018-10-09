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

enum Climate{FOREST(    135, 150, 4,  5, 30, -10, 25, 2.0, 2.5,  0.1),
             GRASSLAND(  70, 120, 3,  0, 30, -10, 35, 1.0, 0.5,  0.05),
             MOUNTAIN(   30, 75,  2, -5, 25, -25, 15, 4.0, 1.25, 0.25),
             SWAMP(     170, 100, 5,  5, 35,  -5, 20, 1.5, 1.0,  0.1),
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