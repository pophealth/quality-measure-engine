describe QME::Importer::SectionImporter do
  before do
    @si = QME::Importer::SectionImporter.new('/cda:simple/cda:entry')
    @doc = Nokogiri::XML(File.new('fixtures/section_importer.xml'))
    @doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
  end
  
  it "should be able to extract a date list property" do
    property_description = {
      "type" => "array",
      "items" =>  {
        "type" => "number"
      },
      "codes" =>  [
        {
          "set" => "SNOMED-CT",
          "values" => ["314443004"]
        }
      ]
    }
    
    result = @si.extract_date_list_based_on_section(@doc, property_description)
    result.should include(1026777600)
    result.length.should == 2
  end
  
  it "should be able to extract a date/value list property" do
    property_description = {
      "type" => "array",
      "items" => {
        "type" => "object",
        "properties" => {
          "value" => {
            "type" => "number"
          },
          "date" =>  {
            "type" => "number"
          }
        }
      },
      "codes" =>  [
        {
          "set" => "SNOMED-CT",
          "values" => ["314443004"]
        }
      ]
    }
    
    result = @si.extract_value_date_list_based_on_section(@doc, property_description)
    result.should include({'date' => 1026777600, 'value' => 'eleventeen'})
    result.length.should == 1
  end
  
  it "should be able to extract a date range property" do
    property_description = {
      "type" => "array",
      "items" => {
        "type" => "object",
        "properties" => {
          "start" => {
            "type" => "number"
          },
          "end" =>  {
            "type" => "number"
          }
        }
      },
      "codes" =>  [
        {
          "set" => "SNOMED-CT",
          "values" => ["194774006"]
        }
      ]
    }
    
    result = @si.extract_date_range_list_based_on_section(@doc, property_description)
    result.should include({'start' => 1026777600, 'end' => 1189814400})
    result.length.should == 1
  end
  
  it "should raise an error when it can't determine the property schema" do
    property_description = {
      "type" => "cheese",
      "description"  => "A cheesey example"
    }
    expect {@si.extract(@doc, property_description)}.to raise_error
  end
end