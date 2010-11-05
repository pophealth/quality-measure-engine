describe QME::Importer::Measure::PneumoniaVaccinationStatus do
  it "should import the the information relevant to determining pneumonia vaccination status" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0043/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = {}
    ns_context = Nokogiri::NamespaceContext.new(doc.root, {"cda"=>"urn:hl7-org:v3"})
    
    raw_measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    measure_json = JSON.parse(raw_measure_json)
    
    pvs = QME::Importer::Measure::PneumoniaVaccinationStatus.new(measure_json)
    measure_info = pvs.parse(ns_context)
    
    measure_info['vaccination'].should == 1248825600
    measure_info['encounter'].should == 1270598400
  end
end