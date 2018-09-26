class MapSettings extends Settings{
  int mapWidth, mapHeight;
  
  NoiseMap noise;
  int noiseWidth, noiseHeight;
  float noiseXOff, noiseYOff;
  float noiseScale;
  int overSampling;
  
  float seeLevel;
  float mountainsLevel;
  
  
  MapSettings(){
    mapWidth = mapHeight = 10;
    
    noiseXOff = noiseYOff = 0;
    noiseScale = 4;
    overSampling = 0;
    noiseWidth = mapWidth * (int) pow(4, overSampling);
    noiseHeight = mapHeight * (int) pow(4, overSampling);
    
    seeLevel = 0.3;
  }
}

class MapGenerator{
  private MapSettings settings;
  public Map map;
  
  MapGenerator(MapSettings settings){
    this.settings = settings;
    map = new Map(settings.mapWidth, settings.mapHeight);
  }
  
  private float[][] generateLandMass(float[][] noise){
    float[][] land = new float[settings.noiseHeight][settings.noiseWidth];
    
    for(int j=0; j<settings.noiseHeight; ++j){
      for(int i=0; i<settings.noiseWidth; ++i){
        float value = noise[j][i];
        land[j][i] = value - settings.seeLevel;
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