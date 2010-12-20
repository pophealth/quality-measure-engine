describe QME::Importer::PatientImporter do
  before do
    @loader = QME::Database::Loader.new('test')
    measures = Dir.glob('measures/*')
    @loader.drop_collection('measures')
    measures.each do |dir|
      @loader.save_measure(dir, 'measures')
    end
  end
  
  it "should import demographic information" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/demographics.xml'))
    patient = {}
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    QME::Importer::PatientImporter.instance.get_demographics(patient, doc)
    
    patient['first'].should == 'Joe'
    patient['last'].should == 'Smith'
    patient['birthdate'].should == -87696000
    patient['gender'].should == 'M'
  end
  
  it 'should import a whole patient' do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0032/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    
    QME::Importer::PatientImporter.instance.initialize_measures(@loader.get_db)
    
    patient = QME::Importer::PatientImporter.instance.parse_c32(doc)
    
    patient['first'].should == 'FirstName'
    patient['measures']['0032']['encounter_outpatient'].should == 1270598400
    patient['measures']['0043']['encounter'].should == 1270598400
  end
end