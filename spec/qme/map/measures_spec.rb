describe QME::MapReduce::Executor do

  before do
    @loader = QME::Database::Loader.new('test')
    @measures = Dir.glob('measures/*')
  end
  
  it 'should produce a list of available measures' do
    @loader.drop_collection('measures')
    @measures.each do |dir|
      @loader.save_measure(dir, 'measures')
    end
    executor = QME::MapReduce::Executor.new(@loader.get_db)
    measure_list = executor.all_measures
    measure_list.should have_key('0001')
    measure_list.should have_key('0013')
    measure_list.should have_key('0032')
    measure_list.should have_key('0036')
    measure_list.should have_key('0043')
    measure_list.should have_key('0041')
    measure_list.should have_key('0055')
    measure_list.should have_key('0056')
    measure_list.should have_key('0059')
    measure_list.should have_key('0061')
    measure_list.should have_key('0062')
    measure_list.should have_key('0421')
    measure_list.should have_key('0028')
    
    hypertension = measure_list['0013']
    hypertension[:id].should eql('0013')
    hypertension[:variants].should have(0).items
    hypertension[:category].should eql('Core')
    bmi = measure_list['0421']
    bmi[:id].should eql('0421')
    bmi[:variants].should have(2).items
    bmi[:category].should eql('Core')
  end
  
  it 'should produce the expected results for each measure' do
    validate_measures(@measures,@loader)
  
  end
  
end
