describe QME::Importer::Measure::DiabetesEyeExam do
  it "should import the the information relevant to determining diabetic eye exam measure status" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/diabetes/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = {}
    
    raw_measure_json = File.read('measures/diabetes/components/root.json')
    measure_json = JSON.parse(raw_measure_json)

    dee = QME::Importer::Measure::DiabetesEyeExam.new(measure_json)
    measure_info = dee.parse(doc)

    measure_info['encounter_acute_inpatient'].should ==                    1275177600 # Time.gm(2010, 5, 30).to_i
    measure_info['encounter_non_acute_inpatient'].should ==                1275177600 # Time.gm(2010, 5, 30).to_i
    measure_info['encounter_outpatient'].should ==                         1275177600 # Time.gm(2010, 5, 30).to_i
    measure_info['encounter_outpatient_opthamological_services'].should == 1275177600 # Time.gm(2010, 5, 30).to_i
    
    measure_info['medications_indicative_of_diabetes'].should == 1275177600 # Time.gm(2010, 5, 30).to_i
    
    measure_info['diagnosis_diabetes'].should ==                 1275177600 # Time.gm(2010, 5, 30).to_i
    measure_info['diagnosis_gestational_diabetes'].should ==     1275177600 # Time.gm(2010, 5, 30).to_i
    measure_info['diagnosis_steroid_induced_diabetes'].should == 1275177600 # Time.gm(2010, 5, 30).to_i
    measure_info['polycystic_ovaries'].should ==                 1275177600 # Time.gm(2010, 5, 30).to_i
    
    #measure_info['proceedure_eye_exam'].should ==                1275177600 # Time.gm(2010, 5, 30).to_i
  end
end