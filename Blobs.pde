class Blob{
  List<Vector2<Integer>> locations;
  
  public Blob(){
    locations = new ArrayList();
  }
  
  public void add(Vector2<Integer> e){
    locations.add(e);
  }
  public void remove(Vector2<Integer> e){
    locations.remove(e);
  }
  public int count(){
    return locations.size();
  }
}

class TileBlob{
  List<Tile> tiles;
  
  public TileBlob(){
    tiles = new ArrayList();
  }
  
  public void add(Tile t){
    tiles.add(t);
  }
  public void remove(Tile t){
    tiles.remove(t);
  }
  public int count(){
    return tiles.size();
  }
}



public List<Blob> getBlobs(int[][] bitArray, int w, int h){
  HashMap<Integer, List<Integer>> map = new HashMap();
  int index = 1;
  
  //First label
  for(int j=0; j<h; ++j){
    for(int i=0; i<w; ++i){
      if(bitArray[j][i] != 0){
        Vector2<Integer> group = nearGroups(bitArray, i, j);
        if(group.e1==0 && group.e2==0){
          bitArray[j][i] = index;
          map.put(index, new ArrayList<Integer>());
          map.get(index).add(index);
          ++index;
        }else{
          if(group.e1 != 0) bitArray[j][i]=group.e1;
          else bitArray[j][i]=group.e2;
          
          if(group.e2!=0 && bitArray[j][i]!=group.e2){
            for(List<Integer> l : map.values()){
              if(l.contains(group.e1)){
                List<Integer> eq = map.get(group.e2);
                Collections.sort(eq);
                if(!l.contains(eq.get(0))) l.add(eq.get(0));
              }
              if(l.contains(group.e2)){
                List<Integer> eq = map.get(group.e1);
                Collections.sort(eq);
                if(!l.contains(eq.get(0))) l.add(eq.get(0));
              }
            }
          }
        }
      }
    }
  }
  
  //sort arrays
  for(int i : map.keySet()){
    Collections.sort(map.get(i));
  }
  
  HashMap<Integer, Blob> blobs = new HashMap();
  
  //Uniform label
  for(int j=0; j<h; ++j){
    for(int i=0; i<w; ++i){
      int v = bitArray[j][i];
      if(v != 0){
        bitArray[j][i] = map.get(v).get(0);
        v = bitArray[j][i];
        if(blobs.containsKey(v)) blobs.get(v).add(new Vector2<Integer>(i, j));
        else{
          blobs.put(v, new Blob());
          blobs.get(v).add(new Vector2<Integer>(i, j));
        }
      }
    }
  }
  
  return new ArrayList(blobs.values());
}

private Vector2<Integer> nearGroups(int[][] bitArray, int x, int y){
  int e1=0, e2=0;
  if(x-1>=0 && bitArray[y][x-1]!=0) e1 = bitArray[y][x-1];
  if(y-1>=0 && bitArray[y-1][x]!=0) e2 = bitArray[y-1][x];
  
  return new Vector2(e1, e2);
}

public int[][] getBitArray(float[][] array, int w, int h, float threshold){
  int[][] bitArray = new int[h][w];
  
  for(int j=0; j<h; ++j){
    for(int i=0; i<w; ++i){
      if(array[j][i] <= threshold) bitArray[j][i] = 0;
      else bitArray[j][i] = 1;
    }
  }
  
  return bitArray;
}

public List<TileBlob> blobsToTile(List<Blob> blobs, Tile[][] tiles){
  List<TileBlob> tBlobs = new ArrayList();
  
  for(Blob b : blobs){
    TileBlob tb = new TileBlob();
    for(Vector2<Integer> v : b.locations){
      tb.add(tiles[v.e2][v.e1]);
    }
    tBlobs.add(tb);
  }
  
  return tBlobs;
}