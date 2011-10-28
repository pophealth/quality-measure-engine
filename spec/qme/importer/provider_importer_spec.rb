describe QME::Importer::ProviderImporter do
  before do
    @doc = Nokogiri::XML(File.new("fixtures/c32_fragments/provider.xml"))
    @doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    @importer = QME::Importer::ProviderImporter.instance
  end
  
  it "should extract providers from document" do
    providers = @importer.extract_providers(@doc)

    providers.size.should == 2
    
    provider = providers.first
    provider[:title].should == "Dr."
    provider[:given_name].should == "Stanley"
    provider[:family_name].should == "Strangelove"
    provider[:phone].should == "+1-301-975-3251"
    provider[:npi].should == "0123456789"
    provider[:organization].should == "Kubrick Permanente"
    provider[:specialty].should == "200000000X"
    
    provider2 = providers.last
    provider2[:title].should == "Dr."
    provider2[:given_name].should == "Teddy"
    provider2[:family_name].should == "Seuss"
    provider2[:phone].should == nil
    provider2[:npi].should == nil
    provider2[:organization].should == "Redfish Labs"
    provider2[:specialty].should == "230000000X"
  end
  
end