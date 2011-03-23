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
end