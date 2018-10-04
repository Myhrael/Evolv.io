class MapSettings extends Settings{
  MapSettings(){
    this.addInt("Map width", 100, new Vector2<Integer>(100, 500), Step.arythmeticInt(1));
    this.addInt("Map height", 100, new Vector2<Integer>(100, 500), Step.arythmeticInt(1));
    
    this.addFloat("Noise offset (x)", 0f, new Vector2<Float>(0f, 100f), Step.arythmeticFloat(0.2));
    this.addFloat("Noise offset (y)", 0f, new Vector2<Float>(0f, 100f), Step.arythmeticFloat(0.2));
    this.addFloat("Noise scale", 0.1, new Vector2<Float>(0f, 1f), Step.arythmeticFloat(0.01));
    
    this.addInt("Over-sampling", 0, new Vector2<Integer>(0, 8), Step.arythmeticInt(1));
    
    this.addFloat("See level", 0.3f, new Vector2<Float>(0f, 1f), Step.arythmeticFloat(0.05));
    this.addFloat("Mountains level", 0.8f, new Vector2<Float>(0f, 1f), Step.arythmeticFloat(0.05));
    
    this.addBool("Auto update", true);
  }
  
  private int noiseWidth(){ return int(getInt("Map width") * pow(4, getInt("Over-sampling"))); }
  private int noiseHeight(){ return int(getInt("Map height") * pow(4, getInt("Over-sampling"))); }
}

class MapGenerator{
  NoiseMap noiseMap;
  private MapSettings settings;
  public Map map;
  
  MapGenerator(MapSettings settings){
    this.settings = settings;
    noiseMap = new NoiseMap();
    map = new Map(int(settings.getInt("Map width")), int(settings.getInt("Map height")), true);
  }
  
  public void update(){
    if(settings.hasChanged() && settings.getBool("Auto update")) generate();
  }
  
  public void generate(){
    Tile[][] baseMap = generateLandMass(noiseMap.generate(settings.noiseWidth(), settings.noiseHeight(), 
      settings.getFloat("Noise offset (x)"), settings.getFloat("Noise offset (y)"),
      settings.getFloat("Noise scale")));
    
    
    
    map.set(baseMap, settings.getInt("Map width"), settings.getInt("Map height"));
  }
  
  private float[][] generateNoise(){
    int noiseHeight = settings.noiseHeight();
    int noiseWidth = settings.noiseWidth();
    float[][] noise = noiseMap.generate(noiseWidth, noiseHeight, settings.getFloat("Noise offset (x)"),
          settings.getFloat("Noise offset (y)"), settings.getFloat("Noise scale"));
    
    int overSamp = settings.getInt("Over-sampling");
    
    for(int j=0; j<noiseHeight; ++j){
      for(int i=0; i<noiseWidth; ++i){
        
      }
    }
    
    return noise;
  }
  
  private Tile[][] generateLandMass(float[][] noise){
    int mapHeight = settings.getInt("Map height");
    int mapWidth = settings.getInt("Map width");
    Tile[][] tiles = new Tile[mapHeight][mapWidth];
    
    float seeLevel = settings.getFloat("See level");
    float mountainLevel = settings.getFloat("Mountains level");
    mountainLevel = mountainLevel<seeLevel ? seeLevel : mountainLevel;
    
    for(int j=0; j<mapHeight; ++j){
      for(int i=0; i<mapWidth; ++i){
        float value = noise[j][i];
        if(value < seeLevel){
          value = map(value, 0, seeLevel, -10, 0);
          tiles[j][i] = new Tile(Climate.WATER, value);
        }else if(value < mountainLevel){
          value = map(value, seeLevel, mountainLevel, 0, 10);
          tiles[j][i] = new Tile(value);
        }else{
          value = map(value, mountainLevel, 1, 10, 20);
          tiles[j][i] = new Tile(Climate.MOUNTAIN, value);
        }
      }
    }
    
    return tiles;
  }
}

class NoiseMap{
  float[][] generate(int w, int h, float xOff, float yOff, float scale){
    float[][] map = new float[h][w];
    
    for(int j=0; j<h; ++j){
      for(int i=0; i<w; ++i){
        float x = map(j, 0, h, 0, 1) / scale + xOff;
        float y = map(i, 0, w, 0, 1) / scale + yOff;
        
        map[j][i] = noise(x, y);
      }
    }
    
    return map;
  }
}