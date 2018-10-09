class MapSettings extends Settings{
  MapSettings(){
    this.addInt("Map width", 250, new IntRange(100, 500), Step.arythmeticInt(1));
    this.addInt("Map height", 250, new IntRange(100, 500), Step.arythmeticInt(1));
    
    this.addFloat("Noise offset (x)", 10f, new FloatRange(0f, 20f), Step.arythmeticFloat(0.05));
    this.addFloat("Noise offset (y)", 10f, new FloatRange(0f, 20f), Step.arythmeticFloat(0.05));
    this.addFloat("Noise scale", 0.5, new FloatRange(0.1f, 0.9f), Step.arythmeticFloat(0.01));
    
    this.addFloat("See level", 0.3f);
    this.addFloat("Mountains level", 0.8f);
    this.addFloat("Max value", 0);
    this.addFloat("Min value", 1);
    this.setFloatRange("Mountains level", new FloatRange(this.getFloatSetting("See level").getObsValue(), 
                        this.getFloatSetting("Max value").getObsValue()), Step.arythmeticFloat(0.01));
    this.setFloatRange("See level", new FloatRange(this.getFloatSetting("Min value").getObsValue(), 
                        this.getFloatSetting("Mountains level").getObsValue()), Step.arythmeticFloat(0.01));
    
    this.addInt("Rivers treshold", 15, new IntRange(5, 35), Step.arythmeticInt(1));
    this.addBool("Rivers enabled", false);
    
    this.addInt("Climate amount", 20, new IntRange(10, 200), Step.arythmeticInt(1));
    
    this.addBool("Auto update", true);
  }
  
  public int noiseWidth(){ return int(getInt("Map width") * pow(2, getInt("Over-sampling"))); }
  public int noiseHeight(){ return int(getInt("Map height") * pow(2, getInt("Over-sampling"))); }
}

class MapGenerator{
  public Map map;
  
  private NoiseMap noiseMap;
  private List<TileBlob> tileBlobs;
  
  private MapSettings settings;
  private ObservableFloat minValue, maxValue;
  
  MapGenerator(MapSettings settings){
    this.settings = settings;
    minValue = settings.getFloatSetting("Min value").getObsValue();
    maxValue = settings.getFloatSetting("Max value").getObsValue();
    noiseMap = new NoiseMap();
    map = new Map(int(settings.getInt("Map width")), int(settings.getInt("Map height")), true);
  }
  
  public void update(){
    if(settings.getBool("Auto update")) generate();
  }
  
  public void generate(){
    int mapWidth = settings.getInt("Map width");
    int mapHeight = settings.getInt("Map height");
    float seeLevel = settings.getFloat("See level");
    
    float[][] noise;
    boolean noiseChanged = false;
    if(settings.getIntSetting("Map width").hasChanged() || settings.getIntSetting("Map height").hasChanged()
      || settings.getFloatSetting("Noise offset (x)").hasChanged() || settings.getFloatSetting("Noise offset (y)").hasChanged()
      || settings.getFloatSetting("Noise scale").hasChanged()){
          noise = generateNoise();
          noiseChanged = true;
    }else noise = noiseMap.map;
    
    Tile[][] baseMap;
    boolean baseMapChanged = false;
    if(settings.getFloatSetting("See level").hasChanged() || settings.getFloatSetting("Mountains level").hasChanged()
      || noiseChanged){
          baseMap = generateLandMass(noise);
          tileBlobs = blobsToTile(getBlobs(getBitArray(noise, mapWidth, mapHeight, seeLevel), mapWidth, mapHeight), baseMap);
          baseMapChanged = true;
    }else baseMap = map.tiles;
    
    
    
    if(settings.getIntSetting("Climate amount").hasChanged() || baseMapChanged){
      putClimateSeeds(tileBlobs, baseMap);
    }
    map.set(baseMap, settings.getInt("Map width"), settings.getInt("Map height"));
    
    if(settings.getBool("Rivers enabled")) generateRivers();
  }
  
  public void generateClimates(List<TileBlob> blobs, Tile[][] tileMap){
    expandClimates(blobs, tileMap);
    while(expandClimates(blobs, tileMap));
  }
  private void putClimateSeeds(List<TileBlob> blobs, Tile[][] tileMap){
    int tileCount = 0;
    for(TileBlob b : blobs){
      tileCount += b.count();
      
      //Clean tiles climate
      for(Tile t : b.tiles){
        if(t.climate != Climate.MOUNTAIN) t.climate = null;
      }
    }
    float climatePerTile = (float) settings.getInt("Climate amount") / tileCount;
    
    for(TileBlob b : blobs){
      int climateToSpawn = int(climatePerTile * b.count());
      if(climateToSpawn < 1) climateToSpawn = 1;
      
      List<Tile> removed = new ArrayList();
      for(int i=0; i<climateToSpawn; ++i){
        Tile tile;
        do{
          tile = b.tiles.get(int(random(b.count())));
        }while(tile.climate == Climate.MOUNTAIN);
        removed.add(tile);
        b.remove(tile);
        
        float r = random(2);
        if(tileHasClimateInRange(tileMap, tile.x, tile.y, settings.getInt("Map width"), settings.getInt("Map height"), 10, Climate.WATER)){
          if(r < 0.9) tile.setClimate(Climate.FOREST);
          else if(r<1.7) tile.setClimate(Climate.GRASSLAND);
          else tile.setClimate(Climate.SWAMP);
        }else{
          if(r<1.1) tile.setClimate(Climate.GRASSLAND);
          else tile.setClimate(Climate.FOREST);
        }        
      }
      for(Tile t : removed) b.add(t);
    }
  }
  private boolean expandClimates(List<TileBlob> blobs, Tile[][] tileMap){
    int mapWidth = settings.getInt("Map width");
    int mapHeight = settings.getInt("Map height");
    Tile[][] newMap = new Tile[mapHeight][mapWidth];
    for(int j=0; j<mapHeight; ++j){
      for(int i=0; i<mapWidth; ++i){
        newMap[j][i] = new Tile(i, j);
      }
    } 
    boolean remain = false;
    List<TileBlob> removed = new ArrayList();
    
    for(int i=0; i<blobs.size(); ++i){
      TileBlob b = blobs.get(i);
      boolean tmpRemain = false;
      for(Tile tile : b.tiles){
        if(tile.climate != Climate.WATER && tile.climate != Climate.MOUNTAIN){
          int[] count = getClimateCount(tileMap, tile.x, tile.y, mapWidth, mapHeight);
          int index = getMaxIndex(count);
          
          if(count[index] > 0){
            switch(index){
              case 0: newMap[tile.y][tile.x].setClimate(Climate.FOREST); break;
              case 1: newMap[tile.y][tile.x].setClimate(Climate.GRASSLAND); break;
              case 2: newMap[tile.y][tile.x].setClimate(Climate.SWAMP); break;
              default: if(tile.climate == null){
                remain = true;
                tmpRemain = true;
              }
            }
          }else{
            remain = true;
            tmpRemain = true;
          }
        }
      }
      if(tmpRemain == false){
        removed.add(b);
        blobs.remove(b);
      } 
    }
    for(int j=0; j<mapHeight; ++j){
      for(int i=0; i<mapWidth; ++i){
        Tile newTile = newMap[j][i];
        if(newTile.climate!=null){
          tileMap[j][i].setClimate(newTile.climate);
        }
      }
    }
    for(TileBlob tb : removed) blobs.add(tb);
    
    return remain;
  }
  private int getMaxIndex(int[] array){
    int index = -1;
    int[] clone = array.clone();
    int last = clone.length-1;
    Arrays.sort(clone);
    
    //Compute nbr of equal max value
    int nbr = 1;
    while(clone[last-nbr] == clone[last] && last-nbr>0) ++nbr;
    //Choose one at random
    int r = int(random(nbr));
    int n = 0;
    for(int i=0; i<array.length; ++i){
      if(array[i] == clone[last]){
        if(n == r) index = i;
        else ++n;
      }
    }
    
    return index;
  }
  private int[] getClimateCount(Tile[][] tileMap, int x, int y, int w, int h){
    int[] count = new int[3];
    for(int j=y-1; j<=y+1 && j<h; ++j){
      if(j>=0){
        for(int i=x-1; i<=x+1 && i<w; ++i){
          if(i>=0){
            int a = (i==x && j==y) ? 3 : 1;
            if(tileMap[j][i].climate != null){
              switch(tileMap[j][i].climate){
                case FOREST: count[0]+=a; break;
                case GRASSLAND: count[1]+=a; break;
                case SWAMP: count[2]+=a; break;
                default: 
              }
            }
          }
        }
      }
    }
    return count;
  }
  
  public void generateRivers(){
    int mapWidth = settings.getInt("Map width");
    int mapHeight = settings.getInt("Map height");
    float seeLevel = settings.getFloat("See level");
    
    float[][] heightMap = noiseMap.getMap();
    for(int j=0; j<mapHeight; ++j){
      for(int i=0; i<mapWidth; ++i){
        if(heightMap[j][i]<=seeLevel) heightMap[j][i]=seeLevel;
      }
    }    
    float[][] water = new float[mapHeight][mapWidth];
    for(int j=0; j<mapHeight; ++j){
      for(int i=0; i<mapWidth; ++i){
        water[j][i]=1;
      }
    }
    Vector2<Integer>[][] gradients = new Vector2[mapHeight][mapWidth];
    for(int j=0; j<mapHeight; ++j){
      for(int i=0; i<mapWidth; ++i){
        gradients[j][i] = getLowestGrad(i, j, mapWidth, mapHeight, heightMap, water);
      }
    }
    
    for(int j=0; j<mapHeight; ++j){
      for(int i=0; i<mapWidth; ++i){
        Vector2<Integer> grad;
        int x=i;
        int y=j;
        while( (grad=getLowestGrad(x, y, mapWidth, mapHeight, heightMap, water)) != null){
          water[grad.e2][grad.e1] += 1;
          x=grad.e1;
          y=grad.e2;
        }
      }
    }
    for(int j=0; j<mapHeight; ++j){
      for(int i=0; i<mapWidth; ++i){
        if(water[j][i] > 10 * settings.getInt("Rivers treshold")) map.tiles[j][i].setClimate(Climate.WATER);
      }
    }
  }
  
  private Vector2<Integer> getLowestGrad(int i, int j, int w, int h, float[][] heightMap, float[][] waterMap){
    int x, y;
    float grad = 0;
    Vector2<Integer> lowestGrad = null;
    
    for(y=j-1; y<=j+1; ++y){
      if(y>=0 && y<h) {
        for(x=i-1; x<=i+1; ++x){
          if(x>=0 && x<w && ((y==j && x!=i) || (y!=j && x==i))){
            float v = heightMap[y][x]+0.1*waterMap[y][x]-heightMap[j][i]-0.1*waterMap[y][x];
            if(v < grad){ 
              grad = v;
              lowestGrad = new Vector2<Integer>(x, y);
            }
          }
        }
      }
    }
    
    return lowestGrad;
  }
  
  private float[][] generateNoise(){
    int mapWidth = settings.getInt("Map width");
    int mapHeight = settings.getInt("Map height");
    
    float[][] noise = noiseMap.generate(settings.noiseWidth(), settings.noiseHeight(), settings.getFloat("Noise offset (x)"),
          settings.getFloat("Noise offset (y)"), settings.getFloat("Noise scale"));
    minValue.set(noiseMap.min());
    maxValue.set(noiseMap.max());
    
    return noise;
  }
  
  private float expectation(float[][] array, int startI, int startJ, int overSamp){
    if(overSamp == 1) return array[startJ][startI];
    
    float sum = 0;
    int x = startI*overSamp, y = startJ*overSamp;
    for(int j=y; j<y+overSamp; ++j){
      for(int i=x; i<x+overSamp; ++i){
        sum += array[j][i];
      }
    }
    
    return sum/(overSamp*overSamp);
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
          tiles[j][i] = new Tile(Climate.WATER, value, i, j);
        }else if(value > mountainLevel){
          value = map(value, mountainLevel, 1, 10, 20);
          tiles[j][i] = new Tile(Climate.MOUNTAIN, value, i, j);
        }else{
          value = map(value, seeLevel, mountainLevel, 0, 10);
          tiles[j][i] = new Tile(value, i, j);
        }
      }
    }
    
    return tiles;
  }
}

class NoiseMap{
  private float min, max;
  private float[][] map;
  
  public float[][] generate(int w, int h, float xOff, float yOff, float scale){
    map = new float[h][w];
    min = 1; max = 0;
    
    for(int j=0; j<h; ++j){
      for(int i=0; i<w; ++i){
        float x = map(i, 0, w, 0, 1) / scale + xOff;
        float y = map(j, 0, h, 0, 1) / scale + yOff;
        
        float v = noise(x, y);
        map[j][i] = v;
        if(v<min) min = v;
        else if(v>max) max = v;
      }
    }
    
    return map;
  }
  public float min(){ return min; }
  public float max(){ return max; }
  public float[][] getMap(){ return map; }
}