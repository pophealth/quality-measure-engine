MAP_FUNCTION = <<END_OF_MAP_FN
function () {
  var value = {i: 0, d: 0, n: 0, e: 0};
  if (this.birthdate<=-764985600) {
    value.i++;
    if (this.measures["0043"].encounter>=1253318400) {
      value.d++;
      if (this.measures["0043"].vaccination==true) {
        value.n++;
      } else if (false) {
        value.e++;
        value.d--;
      }
    }
  }
  emit(null, value);
};
END_OF_MAP_FN

describe QME::MapReduce::Builder do
  
  before do
    raw_measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    @measure_json = JSON.parse(raw_measure_json)
    raw_measure_json = File.read('fixtures/complex_measure.json')
    @complex_measure_json = JSON.parse(raw_measure_json)
  end

  it 'should extract the measure metadata' do
    measure = QME::MapReduce::Builder.new(@measure_json, :effective_date=>Time.gm(2010, 9, 19).to_i)
    measure.id.should eql('0043')
  end
  it 'should extract three parameters for measure 0043 (one provided, two calculated)' do
    time = Time.gm(2010, 9, 19).to_i

    measure = QME::MapReduce::Builder.new(@measure_json, :effective_date=>time)
    measure.parameters.size.should eql(3)
    measure.parameters.should have_key(:effective_date)
    measure.parameters[:effective_date].should eql(time)
  end
  it 'should raise a RuntimeError if not passed all the parameters' do
    lambda { QME::MapReduce::Builder.new(@measure_json) }.should
      raise_error(RuntimeError, 'No value supplied for measure parameter: effective_date')
  end
  it 'should calculate the calculated dates correctly' do
    date = Time.gm(2010, 9, 19).to_i
    measure = QME::MapReduce::Builder.new(@measure_json, :effective_date=>date)
    measure.parameters[:earliest_encounter].should eql(date-QME::MapReduce::Builder::YEAR_IN_SECONDS)
  end
  it 'should produce valid JavaScript expressions for the query components' do
    date = Time.gm(2010, 9, 19).to_i
    builder = QME::MapReduce::Builder.new(@measure_json, :effective_date=>date)
    builder.numerator.should eql('(this.measures["0043"].vaccination==true)')
    builder.denominator.should eql('(this.measures["0043"].encounter>='+builder.parameters[:earliest_encounter].to_s+')')
    builder.population.should eql('(this.birthdate<='+builder.parameters[:earliest_birthdate].to_s+')')
    builder.exception.should eql('(false)')
    builder.map_function.should eql(MAP_FUNCTION)
    builder.reduce_function.should eql(QME::MapReduce::Builder::REDUCE_FUNCTION)
  end
  it 'should handle logical combinations' do
    builder = QME::MapReduce::Builder.new(@complex_measure_json, {})
    builder.population.should eql('((this.measures["0043"].age>17)&&(this.measures["0043"].age<75)&&((this.measures["0043"].sex=="male")||(this.measures["0043"].sex=="female")))')
  end
end
