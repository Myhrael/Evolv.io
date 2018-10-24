abstract class NeuralNetwork{
  private int size;
  protected Vector2<Integer> stats;
  protected InputLayer inputLayer; 
  protected OutputLayer outputLayer;
  protected List<Layer> hiddenLayers;
  private float learningRate;
  
  public NeuralNetwork(InputLayer inputs, List<Layer> hiddenLayers, OutputLayer outputs){
    inputLayer = inputs; outputLayer = outputs;
    this.hiddenLayers = hiddenLayers;
    stats=computeStats();
    
    size = hiddenLayers.size() + 2;
    learningRate = 0.1f;
  }
  public NeuralNetwork(int[] layersSize){
    hiddenLayers = new ArrayList();
    for(int i=0; i<layersSize.length; ++i){
      if(i==0) inputLayer = new InputLayer(layersSize[i]);
      else if(i==layersSize.length-1) outputLayer = new OutputLayer(layersSize[i]);
      else hiddenLayers.add(new Layer(layersSize[i]));
    }
    
    size = layersSize.length;
    stats=computeStats();
  }
  
  public void init(float[] values){
    for(int i=0; i<values.length; ++i){
      inputLayer.getNeuron(i).setValue(values[i]);
    }
  }
  public void propagate(){
    for(Layer l : hiddenLayers){
      l.propagate();
    }
    outputLayer.propagate();
  }
  public float[] getResult(){
    float[] result = new float[outputLayer.size()];
    
    for(int i=0; i<outputLayer.size(); ++i){
      result[i] = outputLayer.getNeuron(i).getValue();
    }
    
    return result;
  }
  public void learn(float[] expected){
    for(int i=size-1; i>0; --i){
      if(i==size-1) outputLayer.learn(learningRate, expected);
      else hiddenLayers.get(i-1).learn(learningRate);
    }
  }
  
  public void setLerningRate(float a){ learningRate = a; }
  public Vector2<Integer> getStats(){ return stats; }
  private Vector2<Integer> computeStats(){
    int neuronAmount = 0;
    int linkAmount = 0;
    List<Layer> layers = new ArrayList();
    layers.add(inputLayer);
    layers.add(outputLayer);
    layers.addAll(hiddenLayers);
    for(Layer l : layers){
      for(Neuron n : l.getNeurons()){
        neuronAmount += 1;
        linkAmount += n.getLinksL().size();
      }
    }
    return new Vector2(neuronAmount, linkAmount);
  }
}
class FullyConnectedNetwork extends NeuralNetwork{
  public FullyConnectedNetwork(int[] layersSize){
    super(layersSize);
    for(int i=0; i<hiddenLayers.size(); ++i){
      if(i==0) inputLayer.fullConnectToLeft(hiddenLayers.get(i));
      else hiddenLayers.get(i).fullConnectToLeft(hiddenLayers.get(i-1));
    }
    outputLayer.fullConnectToLeft(hiddenLayers.get(hiddenLayers.size()-1));
  }
}

static int[] decreasingLayers(int inputs, int outputs, int layerN){
  int[] layers = new int[layerN];
  int r = (inputs-outputs)/layerN;
  
  int n = inputs;
  for(int i=0; i<layerN; ++i){
    if(i >= layerN-1) layers[i] = outputs;
    else layers[i] = n;
    n -= r;
  }
  
  return layers;
}

class Layer{
  private List<Neuron> neurons;
  
  protected Layer(){
    neurons = new ArrayList();
  }
  public Layer(int size){
    neurons = new ArrayList();
    for(int i=0; i<size; ++i){
      neurons.add(new Neuron(new ActivationFunction.Sigmoid()));
    }
  }
  
  public void fullConnectToLeft(Layer otherLayer){
    for(Neuron neuron : neurons){
      for(Neuron otherNeuron : otherLayer.getNeurons()){
        Link l = new Link(otherNeuron, neuron);
        neuron.addLinkL(l);
        otherNeuron.addLinkR(l);
      }
    }
  }
  public void propagate(){
    for(Neuron n : neurons){
      n.compute();
    }
  }
  public void learn(float learningRate){
    for(Neuron n : neurons){
      n.learn(learningRate);
    }
  }
  
  public List<Neuron> getNeurons(){ return neurons; }
  public Neuron getNeuron(int i){ return neurons.get(i); }
  public int size(){ return neurons.size(); }
}
class InputLayer extends Layer{
  private List<InputNeuron> neurons;
  
  public InputLayer(int size){
    neurons = new ArrayList();
    for(int i=0; i<size; ++i){
      neurons.add(new InputNeuron(new ActivationFunction.Sigmoid()));
    }
  }
  
  public void set(float[] values){
    for(int i=0; i<neurons.size(); ++i){
      neurons.get(i).setValue(values[i]);
    }
  }
  public InputNeuron getNeuron(int i){ return neurons.get(i); }
}
class OutputLayer extends Layer{
  private List<OutputNeuron> neurons;
  
  public OutputLayer(int size){
    neurons = new ArrayList();
    for(int i=0; i<size; ++i){
      neurons.add(new OutputNeuron(new ActivationFunction.Sigmoid()));
    }
  }
  
  public void learn(float learningRate, float[] expected){
    for(int i=0; i<neurons.size(); ++i){
      OutputNeuron n = neurons.get(i);
      n.learn(learningRate, expected[i]);
    }
  }
}

class Neuron{
  protected ActivationFunction f;
  protected float dErr;
  protected float bias;
  protected float value;
  protected List<Link> lLinks;
  protected List<Link> rLinks;
  
  public Neuron(ActivationFunction f){
    lLinks = new ArrayList();
    rLinks = new ArrayList();
    bias = 0;
    value = 0;
    this.f = f;
  }
  
  public void compute(){
    float sum = 0;
    for(Link link : lLinks){
      sum += link.getWeight() * link.getLeft().getValue();
    }
    value = f.getValue(sum + bias);
  }
  public void learn(float learningRate){
    dErr = computeErr();
    
    for(Link link : lLinks){
      link.updateWeight(learningRate, dErr);
    }
    bias += learningRate * dErr;
  }
  private float computeErr(){
    float err = 0;
    for(Link link : rLinks) err += link.getWeight() * link.getRight().getErr();
        
    return err * f.derivative(value);
  }
  
  public void addLinkL(Link link){
    lLinks.add(link);
  }
  public void addLinkR(Link link){
    rLinks.add(link);
  }
  
  public float getErr(){ return dErr; }
  public float getValue(){ return value; }
  public List<Link> getLinksL(){ return lLinks; }
  public List<Link> getLinksR(){ return rLinks; }
}
class InputNeuron extends Neuron{
  public InputNeuron(ActivationFunction f){
    super(f);
  }
  
  public void setValue(float v){ value = v; }
}
class OutputNeuron extends Neuron{
  public OutputNeuron(ActivationFunction f){
    super(f);
  }
  
  public void learn(float learningRate, float expected){
    dErr = computeErr(expected);
    
    for(Link link : lLinks){
      link.updateWeight(learningRate, dErr);
    }
    bias += learningRate * dErr;
  }
  public float computeErr(float expected){
    return (expected - value) * f.derivative(value);
  }
}

class Link{
  private Neuron left, right;
  private float weight;
  
  public Link(Neuron left, Neuron right){
    this(left, right, 0);
  }
  public Link(Neuron left, Neuron right, float weight){
    this.left = left; this.right=right;
    this.weight = weight;
  }
  
  public void updateWeight(float learningRate, float err){ 
    weight += learningRate*err*left.getValue(); 
  }
  public Neuron getLeft(){ return left; }
  public Neuron getRight(){ return right; }
  public float getWeight(){ return weight; }
}

interface ActivationFunction{
  public static class Sigmoid implements ActivationFunction{
    public float getValue(float x){ return 1/(1+exp(-x)); }
    public float derivative(float x){
      float y = getValue(x);
      return y*(1-y);
    }
  }
  
  public float getValue(float x);
  public float derivative(float x);
}