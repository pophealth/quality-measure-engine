describe QME::QualityReport do
  before do
    loader = QME::Database::Loader.new
    loader.drop_collection('query_cache')
    loader.drop_collection('patient_cache')
    loader.get_db['query_cache'].save(
      "measure_id" => "test2",
      "sub_id" =>  "b",
      "initialPopulation" => 4,
      "numerator" => 1,
      "denominator" => 2,
      "exclusions" => 1,
      "effective_date" => Time.gm(2010, 9, 19).to_i
    )
    loader.get_db['patient_cache'].save(
      "value" => {
        "population" => false,
        "denominator" => false,
        "numerator" => false,
        "exclusions" => false,
        "antinumerator" => false,
        "medical_record_id" => "0616911582",
        "first" => "Mary",
        "last" => "Edwards",
        "gender" => "F",
        "birthdate" => Time.gm(1940, 9, 19).to_i,
        "test_id" => nil,
        "provider_performances" => nil,
        "race" => {
          "code" => "2106-3",
          "code_set" => "CDC-RE"
        },
        "ethnicity" => {
          "code" => "2135-2",
          "code_set" => "CDC-RE"
        },
        "measure_id" => "test2",
        "sub_id" =>  "b",
        "effective_date" => Time.gm(2010, 9, 19).to_i 
      }
    )
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
  
  it "should be able to clear all of the quality reports" do
    QME::QualityReport.destroy_all
    
    qr = QME::QualityReport.new('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    qr.calculated?.should be_false
  end
  
  it "should be remove results for updated patients" do
    qr = QME::QualityReport.new('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    qr.calculated?.should be_true
    qr.patients_cached?.should be_true
    QME::QualityReport.update_patient_results("0616911582")
    qr.calculated?.should be_false
    qr.patients_cached?.should be_false    
  end
end