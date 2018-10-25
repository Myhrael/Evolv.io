class Brain extends Organ{
  private AI ai;  
  
  public Brain(BodyPart body, List<Rule> rules){
    super(body);
    ai = new AI(body.getStatus(), body.getActions(), rules);
  }
  
  public float _use(){
    int iterations = ai.act();
    return iterations*ai.size()*0.001f;
  }
}