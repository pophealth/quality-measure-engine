describe QME::Importer::Measure::PneumoniaVaccinationStatus do
  before do
    @loader = load_measures
  end

  it "should import the the information relevant to determining pneumonia vaccination status" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0043/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = {}

    pvs = QME::Importer::Measure::PneumoniaVaccinationStatus.new(measure_definition(@loader, '0043'))
    measure_info = pvs.parse(doc)

    measure_info['vaccination'].should == 1248825600
    measure_info['encounter'].should == 1270598400
  end
end