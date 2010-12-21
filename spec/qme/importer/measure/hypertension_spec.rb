describe QME::Importer::Measure::Hypertension do
  before do
    @loader = load_measures
  end

  it "should import the information relevant to determining hypertension blood pressure measurement" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0013/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    patient = {}

    hbpm = QME::Importer::Measure::Hypertension.new(measure_definition(@loader, '0013'))
    measure_info = hbpm.parse(doc)

    measure_info['encounter_outpatient'].should == 1270598400    
    measure_info['hypertension'].should == 1262304000
    measure_info['diastolic_blood_pressure'].should == 942537600
    measure_info['systolic_blood_pressure'].should == 942537600
  end
end