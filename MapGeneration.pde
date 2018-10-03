class MapSettings extends Settings{
  MapSettings(){
    this.addInt("Map width", 10, 10, 100);
    this.addInt("Map height", 10, 10, 100);
    
    this.addFloat("Noise offset (x)", 0f, 0f, 1000f);
    this.addFloat("Noise offset (y)", 0f, 0f, 1000f);
    this.addFloat("Noise scale", 4f, 1f, 10f);
    
    this.addInt("Over-sampling", 0);
    
    this.addFloat("See level", 0.3f, 0f, 1f);
    this.addFloat("Mountains level", 0.8f, 0f, 1f);
    
    this.addBool("Auto update", true);
  }
  
  private int noiseWidth(){ return int(getInt("Map width").get() * pow(4, getInt("Over-sampling").get())); }
  private int noiseHeight(){ return int(getInt("Map height").get() * pow(4, getInt("Over-sampling").get())); }
}

class MapGenerator{
  NoiseMap noise;
  private MapSettings settings;
  public Map map;
  
  MapGenerator(MapSettings settings){
    this.settings = settings;
    noise = new NoiseMap();
    map = new Map(int(settings.getInt("Map width").get()), int(settings.getInt("Map height").get()));
  }
  
  public void generate(){
    float[][] baseMap = generateLandMass(noise.generate(settings.noiseWidth(), settings.noiseHeight(), 
      settings.getFloat("Noise offset (x)").get(), settings.getFloat("Noise offset (y)").get(),
      settings.getFloat("Noise scale").get()));
  }
  
  private float[][] generateLandMass(float[][] noise){
    float[][] land = new float[settings.noiseHeight()][settings.noiseWidth()];
    
    for(int j=0; j<settings.noiseHeight(); ++j){
      for(int i=0; i<settings.noiseWidth(); ++i){
        float value = noise[j][i];
        land[j][i] = value - settings.getFloat("See level").get();
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