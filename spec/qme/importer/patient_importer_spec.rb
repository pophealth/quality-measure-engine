describe QME::Importer::PatientImporter do
  it "should import demographic information" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/demographics.xml'))
    patient = {}
    ns_context = Nokogiri::NamespaceContext.new(doc.root, {"cda"=>"urn:hl7-org:v3"})
    QME::Importer::PatientImporter.instance.get_demographics(patient, ns_context)
    
    patient['first'].should == 'Joe'
    patient['last'].should == 'Smith'
    patient['birthdate'].should == -87696000
    patient['gender'].should == 'M'
  end
end