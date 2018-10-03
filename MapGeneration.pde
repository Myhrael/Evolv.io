class MapSettings extends Settings{
  MapSettings(){
    this.addInt("Map width", 25, new Vector2<Integer>(25, 100), Step.arythmeticInt(1));
    this.addInt("Map height", 25, new Vector2<Integer>(25, 100), Step.arythmeticInt(1));
    
    this.addFloat("Noise offset (x)", 0f, new Vector2<Float>(0f, 100f), Step.arythmeticFloat(0.2));
    this.addFloat("Noise offset (y)", 0f, new Vector2<Float>(0f, 100f), Step.arythmeticFloat(0.2));
    this.addFloat("Noise scale", 0.1, new Vector2<Float>(0f, 2f), Step.arythmeticFloat(0.05));
    
    this.addInt("Over-sampling", 0);
    
    this.addFloat("See level", 0.3f, new Vector2<Float>(0f, 1f), Step.arythmeticFloat(0.05));
    this.addFloat("Mountains level", 0.8f, new Vector2<Float>(0f, 1f), Step.arythmeticFloat(0.05));
    
    this.addBool("Auto update", true);
  }
  
  private int noiseWidth(){ return int(getInt("Map width") * pow(4, getInt("Over-sampling"))); }
  private int noiseHeight(){ return int(getInt("Map height") * pow(4, getInt("Over-sampling"))); }
}

class MapGenerator{
  NoiseMap noise;
  private MapSettings settings;
  public Map map;
  
  MapGenerator(MapSettings settings){
    this.settings = settings;
    noise = new NoiseMap();
    map = new Map(int(settings.getInt("Map width")), int(settings.getInt("Map height")));
  }
  
  public void update(){
    generate();
  }
  
  public void generate(){
    float[][] baseMap = generateLandMass(noise.generate(settings.noiseWidth(), settings.noiseHeight(), 
      settings.getFloat("Noise offset (x)"), settings.getFloat("Noise offset (y)"),
      settings.getFloat("Noise scale")));
    map.set(baseMap, (int)(float)settings.getInt("Map width"), (int)(float)settings.getInt("Map height"));
  }
  
  private float[][] generateLandMass(float[][] noise){
    float[][] land = new float[settings.noiseHeight()][settings.noiseWidth()];
    
    for(int j=0; j<settings.noiseHeight(); ++j){
      for(int i=0; i<settings.noiseWidth(); ++i){
        float value = noise[j][i];
        land[j][i] = value; //- settings.getFloat("See level");
      }
    }
    
    return land;
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