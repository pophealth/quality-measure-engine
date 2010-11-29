describe QME::MapReduce::Builder do
  
  before do
    raw_measure_json = File.read('measures/0043/0043_NQF_Pneumonia_Vaccination_Status_For_Older_Adults.json')
    @measure_json = JSON.parse(raw_measure_json)
  end

  it 'should extract the measure metadata' do
    measure = QME::MapReduce::Builder.new(@measure_json, 'effective_date'=>Time.gm(2010, 9, 19).to_i)
    measure.id.should eql('0043')
  end
  it 'should extract one parameter for measure 0043' do
    time = Time.gm(2010, 9, 19).to_i
    measure = QME::MapReduce::Builder.new(@measure_json, 'effective_date'=>time)
    measure.params.size.should eql(1)
    measure.params.should have_key('effective_date')
    measure.params['effective_date'].should eql(time)
  end
  it 'should raise a RuntimeError if not passed all the parameters' do
    lambda { QME::MapReduce::Builder.new(@measure_json) }.should
      raise_error(RuntimeError, 'No value supplied for measure parameter: effective_date')
  end
end

describe QME::MapReduce::Builder::Context do
  it 'should set instance variables from the supplied hash' do
    vars = {'a'=>10, 'b'=>20}
    context = QME::MapReduce::Builder::Context.new(vars)
    binding = context.get_binding
    eval("@a",binding).should eql(10)
    eval("@b",binding).should eql(20)
  end
end
