describe QME::Importer::SectionImporter do
  before do
    @si = QME::Importer::SectionImporter.new('/cda:simple/cda:entry')
    @doc = Nokogiri::XML(File.new('fixtures/section_importer.xml'))
    @doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
  end
  
  it "should be able to extract an entry with a date" do
    entries = @si.create_entries(@doc)
    entry = entries[1]
    entry.time.should == 1026777600
    entry.codes['SNOMED-CT'].should include('314443004')
  end
  
  it "should be able to extract an entry with a date/value list" do
    entries = @si.create_entries(@doc)
    entry = entries[2]
    entry.time.should == 1026777600
    entry.codes['SNOMED-CT'].should include('314443004')
    entry.value[:scalar].should == 'eleventeen'
  end
  
  it "should be able to extract an entry with a date range" do
    entries = @si.create_entries(@doc)
    entry = entries[0]
    entry.start_time.should == 1026777600
    entry.end_time.should == 1189814400
    entry.is_date_range?.should be_true
  end
  
  it "should raise an error when it can't determine the property schema" do
    property_description = {
      "type" => "cheese",
      "description"  => "A cheesey example"
    }
    expect {@si.extract(@doc, property_description)}.to raise_error
  end
end