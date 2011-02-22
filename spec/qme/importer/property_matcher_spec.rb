describe QME::Importer::PropertyMatcher do
  
  it "should raise an error when it can't determine the property schema" do
    property_description = {
      "type" => "cheese",
      "description"  => "A cheesey example"
    }
    
    pm = QME::Importer::PropertyMatcher.new(property_description)
    expect {pm.match([])}.to raise_error
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
    
    pm = QME::Importer::PropertyMatcher.new(property_description)
    
    entry = QME::Importer::Entry.new
    entry.add_code('314443004', 'SNOMED-CT')
    entry.start_time = 1026777600
    
    result = pm.match([entry])
    result.should include(1026777600)
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
    
    pm = QME::Importer::PropertyMatcher.new(property_description)
    
    entry = QME::Importer::Entry.new
    entry.add_code('314443004', 'SNOMED-CT')
    entry.set_value('eleventeen')
    entry.start_time = 1026777600
    
    result = pm.match([entry])
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
    
    pm = QME::Importer::PropertyMatcher.new(property_description)

    entry = QME::Importer::Entry.new
    entry.add_code('194774006', 'SNOMED-CT')
    entry.start_time = 1026777600
    entry.end_time = 1189814400
    
    result = pm.match([entry])
    result.should include({'start' => 1026777600, 'end' => 1189814400})
  end
end