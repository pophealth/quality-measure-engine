describe QME::Importer::GenericImporter do

  it "should properly handle devices" do
    measure_def = {'measure' => {"cardiac_pacer" => {
      "standard_category" => "device",
      "qds_data_type" => "device_applied",
      "type" => "array",
      "items" => {
        "type" => "number",
        "format" => "utc-sec"
      },
      "codes" => [
        {
          "set" => "SNOMED-CT",
          "values" => [
            "14106009",
            "56961003"
          ]
        }
      ]
    }}}
    
    entry = QME::Importer::Entry.new
    entry.add_code('14106009', 'SNOMED-CT')
    entry.start_time = 1026777600
    
    ph = {:medical_equipment => [entry]}
    
    gi = QME::Importer::GenericImporter.new(measure_def)
    measure_info = gi.parse(ph)
    measure_info['cardiac_pacer'].should include(1026777600)
  end
  
  it "should handle active conditions" do
    measure_def = {'measure' => {"silliness" => {
      "standard_category" => "diagnosis_condition_problem",
      "qds_data_type" => "diagnosis_active",
      "type" => "array",
      "items" => {
        "type" => "number",
        "format" => "utc-sec"
      },
      "codes" => [
        {
          "set" => "SNOMED-CT",
          "values" => [
            "14106009",
            "56961003"
          ]
        }
      ]
    }}}
    
    entry1 = QME::Importer::Entry.new
    entry1.add_code('14106009', 'SNOMED-CT')
    entry1.start_time = 1026777600
    entry1.status = :active
    
    entry2 = QME::Importer::Entry.new
    entry2.add_code('14106009', 'SNOMED-CT')
    entry2.start_time = 1026777601
    entry2.status = :inactive
    
    ph = {:conditions => [entry1, entry2]}
    
    gi = QME::Importer::GenericImporter.new(measure_def)
    measure_info = gi.parse(ph)
    measure_info['silliness'].should include(1026777600)
    measure_info['silliness'].should_not include(1026777601)
  end
end