public class WorldSettings extends Settings{
  public WorldSettings(){
    this.addInt("Play speed", 16, new IntRange(1, 16), Step.geometricInt(2));
  }
  
  public int playSpeed(){ return getInt("Play speed"); }
}

public class World{  
  private final float timeStep = 0.5;//how many days pass in 1sec in normal speed
  private float year = 0;
  private WorldSettings settings;
  
  private ArrayList<Creature> creatures;
  private Map map;
  
  World(Map map, WorldSettings settings){
    this.map = map;
    this.settings = settings;
  }
  
  // dt: the elapsed time in sec
  void update(float dt){
    float time = timeStep*dt;
    int playSpeed = settings.playSpeed();
    
    for (int i=0; i<playSpeed; ++i) {
      year += (double)time/365;
      iterate(timeStep*dt);
    }
  }
  
  /*
   * time: delta time expressed in days
   */
  void iterate(float time){
    for(int j=0; j<map.h; ++j){
      for(int i=0; i<map.w; ++i){
        map.tiles[j][i].update(time, year);
      }
    }
  }
}

enum Climate{FOREST(    135, 150, 4,  5, 30, -10, 25, 2.0, 2.5,  0.1),
             GRASSLAND(  70, 120, 3,  0, 30, -10, 35, 1.0, 0.5,  0.05),
             MOUNTAIN(   45, 75,  2, -5, 25, -25, 15, 4.0, 1.25, 0.25),
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