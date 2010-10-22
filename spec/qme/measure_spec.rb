# Test the QME::Measure class

describe QME::Measure do
  it 'should extract the measure metadata' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    measure = QME::Measure.new(hash, :effective_date=>Time.gm(2010, 9, 19).to_i)
    measure.id.should eql('0043')
    measure.name.should eql('Pneumonia Vaccination Status for Older Adults')
    measure.steward.should eql('NCQA')
  end
  it 'should extract three parameters for measure 0043 (one provided, two calculated)' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    time = Time.gm(2010, 9, 19).to_i

    measure = QME::Measure.new(hash, :effective_date=>time)
    measure.parameters.size.should eql(3)
    measure.parameters.should have_key(:effective_date)
    measure.parameters[:effective_date].value.should eql(time)
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
    date = Time.gm(2010, 9, 19).to_i
    measure = QME::Measure.new(hash, :effective_date=>date)
    measure.parameters[:earliest_encounter].value.should eql(date-QME::Measure::YEAR_IN_SECONDS)
  end
end

