describe QME::Importer::Measure::CervicalCancerScreening do
  it "should import the the information relevant to determining cervical cancer screening status" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0032/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = {}
    
    raw_measure_json = File.read('measures/0032/0032_NQF_Cervical_Cancer_Screening.json')
    measure_json = JSON.parse(raw_measure_json)
    
    ccs = QME::Importer::Measure::CervicalCancerScreening.new(measure_json)
    measure_info = ccs.parse(doc)

    measure_info['encounter_outpatient'].should == 1270598400    
    measure_info['pap_test'].should == 1269302400
    measure_info['hysterectomy'].should be_nil
  end
end