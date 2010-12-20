describe QME::Importer::Measure::CervicalCancerScreening do
  before do
    @loader = load_measures
  end
  
  it "should import the the information relevant to determining cervical cancer screening status" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0032/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = {}
    
    ccs = QME::Importer::Measure::CervicalCancerScreening.new(measure_definition(@loader, '0032'))
    measure_info = ccs.parse(doc)

    measure_info['encounter_outpatient'].should == 1270598400    
    measure_info['pap_test'].should == 1269302400
    measure_info['hysterectomy'].should be_nil
  end
end