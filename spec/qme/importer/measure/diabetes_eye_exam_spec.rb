describe QME::Importer::Measure::DiabetesEyeExam do
  before do
    @loader = load_measures
  end
  
  it "should import the the information relevant to determining diabetic eye exam measure status" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/diabetes/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = {}

    dee = QME::Importer::Measure::DiabetesEyeExam.new(measure_definition(@loader, '0055'))
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
    
    # TODO: *rjm  This importer only uses about 90% of the data because the numerator 
    # for all of the diabetes measures is defined in the 'diabetes.col' file.  To really 
    # validate that the diabetes importers are working, the JSON should be extracted
    # from the database, and not the file system.  Once that is done, the next line can 
    # be uncommented and will fully test the importer
    #measure_info['proceedure_eye_exam'].should == 1275177600 # Time.gm(2010, 5, 30).to_i
  end
end