describe QME::Importer::ProviderImporter do
  before do
    @doc = Nokogiri::XML(File.new("fixtures/c32_fragments/provider.xml"))
    @doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    @nist_doc = Nokogiri::XML(File.new("fixtures/c32_fragments/NISTExampleC32.xml"))
    @nist_doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    @importer = QME::Importer::ProviderImporter.instance
  end
  
  it 'should validate npi values' do
    QME::Importer::ProviderImporter::luhn_checksum('7992739871').should == '3'
    QME::Importer::ProviderImporter::valid_npi?('1234567893').should == true
    QME::Importer::ProviderImporter::valid_npi?('808401234567893').should == true
    QME::Importer::ProviderImporter::valid_npi?('1').should == false
    QME::Importer::ProviderImporter::valid_npi?('1010101010').should == false
    QME::Importer::ProviderImporter::valid_npi?('abcdefghij').should == false
  end
  
  it "should extract providers from document" do
    providers = @importer.extract_providers(@doc)

    providers.size.should == 2
    
    provider = providers.first
    provider[:title].should == "Dr."
    provider[:given_name].should == "Stanley"
    provider[:family_name].should == "Strangelove"
    provider[:phone].should == "+1-301-975-3251"
    provider[:npi].should == '808401234567893'
    provider[:organization].should == "Kubrick Permanente"
    provider[:specialty].should == "200000000X"
    
    provider2 = providers.last
    provider2[:title].should == "Dr."
    provider2[:given_name].should == "Teddy"
    provider2[:family_name].should == "Seuss"
    provider2[:phone].should == nil
    provider2[:npi].should == '1234567893'
    provider2[:organization].should == "Redfish Labs"
    provider2[:specialty].should == "230000000X"
  end
  
  it "should extract providers from NIST sample" do
    providers = @importer.extract_providers(@nist_doc)

    providers.size.should == 2
    
    provider = providers.first
    provider[:title].should == "Dr."
    provider[:given_name].should == "Pseudo"
    provider[:family_name].should == "Physician-1"
    provider[:npi].should == '808401234567893'
    provider[:organization].should == "NIST HL7 Test Laboratory"
    provider[:specialty].should == "200000000X"
    
    provider2 = providers.last
    provider2[:title].should == "Dr."
    provider2[:given_name].should == "Pseudo"
    provider2[:family_name].should == "Physician-3"
    provider2[:npi].should == nil
    provider2[:organization].should == "NIST HL7 Test Laboratory"
    provider2[:specialty].should == "200000000X"
  end
  
  it "should extract providers from encounters" do
    providers = @importer.extract_providers(@nist_doc, true)
    providers.size.should == 1
    
    provider = providers.first
    provider[:given_name].should == "John"
    provider[:family_name].should == "Johnson"
    provider[:phone].should == nil
    provider[:npi].should == "808401234567893"
    provider[:organization].should == "Family Doctors"
    provider[:start].should_not == nil
  end
  
end