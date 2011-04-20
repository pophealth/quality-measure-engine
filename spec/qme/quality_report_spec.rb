describe QME::QualityReport do
  before do
    loader = QME::Database::Loader.new
    loader.drop_collection('query_cache')
    loader.get_db['query_cache'].save("measure_id" => "test2",
    "sub_id" =>  "b",
    "initialPopulation" => 4,
    "numerator" => 1,
    "denominator" => 2,
    "exclusions" => 1,
    "effective_date" => Time.gm(2010, 9, 19).to_i)
  end
  
  it "should be able to determine if it has been calculated" do
    qr = QME::QualityReport.new('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    qr.calculated?.should be_true
    
    qr = QME::QualityReport.new('test2', 'b', "effective_date" => Time.gm(2010, 9, 20).to_i)
    qr.calculated?.should be_false
  end
  
  it "should return the result of a calculated quality measure" do
    qr = QME::QualityReport.new('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    result = qr.result
    
    result['numerator'].should == 1
  end
end