# Test the QME::Measure class

invalid_measure_json = <<END_OF_INVALID_MEASURE
{
  "id": "0043",
  "name": "Pneumonia Vaccination Status for Older Adults",
  "steward": "NCQA",
  "parameters": {
    "effective_date": {
      "name": "Effective end date for measure",
      "type": "long"
    }
  },
  "properties": {
    "birthdate": {
      "name": "Date of birth",
      "type": "invalid_type",
      "codes": {
        "HL7": {
          "3.0": ["00110"]
        }
      }
    }
  }
}
END_OF_INVALID_MEASURE

describe QME::Measure do
  it 'should extract the measure metadata' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    measure = QME::Measure.new(hash, :effective_date=>Time.now.to_i)
    measure.id.should eql('0043')
    measure.name.should eql('Pneumonia Vaccination Status for Older Adults')
    measure.steward.should eql('NCQA')
  end
  it 'should extract three properties for measure 0043' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    measure = QME::Measure.new(hash, :effective_date=>Time.now.to_i)
    measure.properties.size.should eql(3)
    measure.properties.should have_key(:birthdate)
    measure.properties.should have_key(:encounter)
    measure.properties.should have_key(:vaccination)
    measure.properties[:birthdate].type.should eql(:long)
    measure.properties[:birthdate].codes.size.should eql(1)
    measure.properties[:birthdate].codes.should have_key('HL7')
    measure.properties[:encounter].type.should eql(:long)
    measure.properties[:encounter].codes.size.should eql(2)
    measure.properties[:encounter].codes.should have_key('CPT')
    measure.properties[:encounter].codes.should have_key('ICD-9-CM')
    measure.properties[:vaccination].type.should eql(:boolean)
  end
  it 'should extract three parameters for measure 0043 (one provided, two calculated)' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    time = Time.now.to_i
    measure = QME::Measure.new(hash, :effective_date=>time)
    measure.parameters.size.should eql(3)
    measure.parameters.should have_key(:effective_date)
    measure.parameters[:effective_date].type.should eql(:long)
    measure.parameters[:effective_date].value.should eql(time)
  end
  it 'should raise a RuntimeError for invalid measures' do
    hash = JSON.parse(invalid_measure_json)
    lambda { QME::Measure.new(hash, :effective_date=>Time.now.to_i) }.should
      raise_error(RuntimeError, 'Unsupported property type: invalid_type')
  end
  it 'should raise a RuntimeError if not passed all the parameters' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    lambda { QME::Measure.new(hash) }.should
      raise_error(RuntimeError, 'No value supplied for measure parameter: effective_date')
  end
  it 'should calculate the calculated dates correctly' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    date = Time.now.to_i
    measure = QME::Measure.new(hash, :effective_date=>date)
    measure.parameters[:earliest_encounter].value.should eql(date-QME::Measure::YEAR_IN_SECONDS)
  end
end

