describe QME::Importer::Measure::HighBloodPressure do
  it "should import the information relevant to determining high blood pressure" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0018/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = {}
    
    raw_measure_json = File.read('measures/0018/0018_NQF_Controlling_High_Blood_Pressure.json')
    measure_json = JSON.parse(raw_measure_json)
    
    chbp = QME::Importer::Measure::HighBloodPressure.new(measure_json)
    measure_info = chbp.parse(doc)

    measure_info['encounter_outpatient'].should == 1239062400    
    measure_info['hypertension'].should == 1258156800
    measure_info['systolic_blood_pressure'].should == [1258156800,"132"]
    measure_info['diastolic_blood_pressure'].should == [1258156800,"86"]
    measure_info['pregnancy'].should be_nil
    measure_info['procedures_indicative_of_esrd'].should be_nil
    measure_info['esrd'].should be_nil
    
  end
end