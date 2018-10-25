class AI{
  private final int size;
  private final SAE_NN sae;
  private final State state;
  private final List<Action> actions;
  private final List<Rule> rules;
  private final CapedList<SAQCorrespondance> pastActions;
  
  private int iterations; //nbr of times the network propagate (forward or backward)
  
  public AI(List<Status> status, List<Action> actions, List<Rule> rules, int memory){
    size = status.size() + actions.size();
    sae = new SAE_NN(size, 2);
    
    state = new State(status);
    this.actions = actions;
    this.rules = rules;
    Collections.sort(rules);
    pastActions = new CapedList(memory);
  }
  
  public int act(){
    iterations = 0;
    
    Pair<Action, Float> pair = chooseBestAction();
    Action action = pair.p1;
    float estimate = pair.p2;
    
    pastActions.push(new SAQCorrespondance(state.clone(), action, estimate));
    float reward = getReward(state, action);
    if(reward != 0){
      correctActions(reward);
      trainSAE();
    }
    
    return iterations;
  }
  private void trainSAE(){
    for(int i=pastActions.size()-1; i>=0; --i){
      SAQCorrespondance step = pastActions.get(i);
      sae.train(step.state(), actions.indexOf(step.action()), step.quality());
      iterations += 2;
    }
  }
  private void correctActions(float reward){
    for(int i=pastActions.size()-1; i>=0; --i){
      SAQCorrespondance step = pastActions.get(i);
      if(i == pastActions.size()-1) step.setQuality(expectedResult(step.quality(), reward));
      else step.setQuality(updateQuality(step.quality(), getReward(step.state(), step.action()), pastActions.get(i+1).quality()));
    }
  }
  private float updateQuality(float q, float r, float nq){
    float a = 0.1f;
    float c = 0.9f;
    return q + a*(r + c*nq - q);
  }
  private float getReward(State state, Action action){
    List<Rule> matching = new ArrayList();
    for(Rule r : rules){
      if(r.match(action, state)) {
        if(matching.isEmpty() || matching.get(0).size() == r.size()) matching.add(r);
        else break;
      };
    }
    
    if(matching.isEmpty()) return 0;
    else{
      int i = floor(random(matching.size()));
      return matching.get(i).getReward();
    }
  }
  private float expectedResult(float quality, float reward){
    return reward<0 ? quality - (quality+1)*(-reward) : reward>0 ? quality + (1-quality)*reward : quality;
  }
  private Pair<Action, Float> chooseBestAction(){
    float bestQ = -1;
    Action bestA = null;
    for(Action action : actions){
      float q = sae.estimate(state, actions.indexOf(action));
      iterations += 1;
      if(q > bestQ){
        bestQ = q;
        bestA = action;
      }
    }
    
    return new Pair<Action, Float>(bestA, bestQ);
  }
  
  public int size(){ return sae.stats.e2; }
}

/*
 * State-Action Estimator artificial Neural Network
 */
class SAE_NN extends FullyConnectedNetwork{
  private int size;
  
  public SAE_NN(int nInputs, int nHiddenLayers){
    super(decreasingLayers(nInputs, 1, nHiddenLayers));
    size = inputLayer.size();
  }
  
  public void train(State s, int actionIndex, float expected){
    init(getInitValues(s, actionIndex));
    propagate();
    learn(new float[]{expected});
  }
  
  public float estimate(State s, int actionIndex){ 
    init(getInitValues(s, actionIndex));
    propagate();
    
    return getResult()[0];
  }
  private float[] getInitValues(State state,int actionIndex){
    float[] values = new float[size];
    List<Status> status = state.getOrderedStatus();
    int ss = status.size();
    
    for(int i=0; i<ss; ++i){
      values[i] = status.get(i).getValue();
    }
    for(int i=0; i<size-ss; ++i){
      if(i == actionIndex) values[ss+i] = 1;
      else values[ss+i] = 0;
    }
    return values;
  }
  
  public float getEstimate(){ return getResult()[0]; }
}

class Rule implements Comparable<Rule>{
  float reward;
  Action action;
  Pair<String, FloatRange>[] status;
  
  public Rule(Pair<String, FloatRange>[] status, Action action, float reward){
    this.reward = reward;
    this.action = action;
    this.status = status;
  }
  
  public boolean match(Action a, State s){
    if(! this.action.equals(a)) return false;
    for(Pair<String, FloatRange> p : status){
      String name = p.p1;
      Status m = s.get(name);
      if(m == null) return false;
      if(!p.p2.contains(m.getValue())) return false;
    }
    return true;
  }
  public float getReward(){ return reward; }
  public int compareTo(Rule other){
    return size()-other.size();
  }
  public int size(){ return status.length; }
}

class State{
  private final HashMap<String, Status> map;
  private final List<Status> orderedStatus;
  
  public State(List<Status> status){
    map = new HashMap();
    for(Status s : status) map.put(s.getName(), s);
    
    status = new ArrayList<Status>();
    for(String s : sort((String[]) map.keySet().toArray())){
      status.add(get(s));
    }
    orderedStatus = status;
  }
  
  public Status get(String s){ return map.get(s); }  
  public List<Status> getOrderedStatus(){ return orderedStatus; }
  public State clone(){
    List<Status> status = new ArrayList();
    for(Status s : orderedStatus){
      status.add(new Status(s.getName(), s.getValue()));
    }
    return new State(status);
  }
}
class Status{
  private final String name;
  private float value;
  
  public Status(String name, float value){
    this.name = name;
    this.value = value;
  }
  
  public String getName(){ return name; }
  public float getValue(){ return value; }
  public boolean getBool(){ return round(value)==0 ? false : true; }
  public void setValue(float v){ value = v<0 ? 0 : v>1 ? 1 : v; }
  public void increase(float v){ setValue(value + v); }
  public void decrease(float v){ setValue(value - v); }
}

abstract class Action{
  public abstract void execute();
  public abstract boolean equals(Object other);
}
class SAQCorrespondance extends Pair<Pair<State,Action>, Float>{
  public SAQCorrespondance(State s, Action a, float q){
    super(new Pair(s, a), q);
  }
  
  public State state(){ return p1.p1; }
  public Action action(){ return p1.p2; }
  public float quality(){ return p2; }
  public void setQuality(float q){ p2 = q; }
}