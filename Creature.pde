class Creature{
  private int x, y;
  private Brain brain;
  private BodyPart body;
  
  public Creature(int x, int y, BodyPart body){
    this.body = body;
  }
  
  public void update(float dt){
    updateStatus();
    float expected = expectedResult(brain.getPrediction(), chooseAction().execute());
    brain.train(expected);
  }
  private void updateStatus(){
    
  }
  
  
  public void draw(float tileSize){
    
  }
  
  public Creature reproduceWith(Creature other){
    Creature newCreature = null;
    
    
    return newCreature;
  }
}

abstract class BodyPart{
  private static final float MAX_ENERGY_PER_UNIT = 10; //maxEnergy for a bodyPart of size 1
  private static final float MAX_SIZE = 25;
  
  
  private Status size;
  private Status energy;
  private List<Organ> organs;
  
  public BodyPart(float size, List<Organ> organs){
    this.size = new Status("Body size", size/MAX_SIZE);
    this.energy = new Status("Body energy", size*MAX_ENERGY_PER_UNIT/2);
    this.organs = organs;
  }
  
  public List<Status> getStatus(){
    List<Status> status = new ArrayList();
    
    status.add(size);
    status.add(energy);
    for(Organ o : organs) status.addAll(o.getStatus());
    
    return status;
  }
  public List<Action> getActions(){
    List<Action> actions = new ArrayList();
    for(Organ o : organs) actions.addAll(o.getActions());
    return actions;
  }
  
  public void drainEnergy(float amount){
    energy.decrease(amount);
  }
  private float maxEnergy(){ return MAX_ENERGY_PER_UNIT * PI*pow(size/2, 2); }
}

abstract class Organ{
  protected BodyPart body;
  protected List<Status> status;
  protected List<Action> actions;
  
  public Organ(BodyPart body){
    this.body = body;
    status = new ArrayList();
    actions = new ArrayList();
  }
  
  public final void use(){
    body.drainEnergy(_use());
  }
  public abstract float _use();
  
  public List<Status> getStatus(){ return status; }
  public List<Action> getActions(){ return actions; }
}