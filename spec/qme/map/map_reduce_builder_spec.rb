describe QME::MapReduce::Builder do
  
  before do
    @loader = QME::Database::Loader.new('test')
    raw_measure_json = File.read(File.join('fixtures', 'entry', 'sample.json'))
    @measure_json = JSON.parse(raw_measure_json)
  end

  it 'should extract the measure metadata' do
    measure = QME::MapReduce::Builder.new(@loader.get_db(), @measure_json, 'effective_date'=>Time.gm(2010, 9, 19).to_i)
    measure.id.should eql('0043')
  end
  it 'should extract one parameter for measure 0043' do
    time = Time.gm(2010, 9, 19).to_i
    measure = QME::MapReduce::Builder.new(@loader.get_db(), @measure_json, 'effective_date'=>time)
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
  before do
    @loader = QME::Database::Loader.new('test')
  end 
  
  it 'should set instance methods from the supplied hash' do
    vars = {'a'=>10, 'b'=>20}
    context = QME::MapReduce::Builder::Context.new(@loader.get_db(), vars)
    binding = context.get_binding
    eval("a",binding).should eql(10)
    eval("b",binding).should eql(20)
  end
end
