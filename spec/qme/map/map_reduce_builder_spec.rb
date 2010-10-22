COMPLEX_MEASURE_JSON = <<END_OF_COMPLEX_MEASURE
{
  "id": "0043",
  "name": "Pneumonia Vaccination Status for Older Adults",
  "steward": "NCQA",
  "population": {
    "and": [
      {
        "category": "Patient Characteristic",
        "title": "Age > 17 before measure period",
        "query": {"age": {"_gt": 17}}
      },
      {
        "category": "Patient Characteristic",
        "title": "Age < 75 before measure period",
        "query": {"age": {"_lt": 75}}
      },
      {
        "or": [
          {
            "category": "Patient Characteristic",
            "title": "Male",
            "query": {"sex": "male"}
          },
          {
            "category": "Patient Characteristic",
            "title": "Female",
            "query": {"sex": "female"}
          }
        ]
      }
    ]
  },
  "denominator": {},
  "numerator": {},
  "exception": {}
}
END_OF_COMPLEX_MEASURE

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
  it 'should extract the measure metadata' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    measure = QME::MapReduce::Builder.new(hash, :effective_date=>Time.gm(2010, 9, 19).to_i)
    measure.id.should eql('0043')
  end
  it 'should extract three parameters for measure 0043 (one provided, two calculated)' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    time = Time.gm(2010, 9, 19).to_i

    measure = QME::MapReduce::Builder.new(hash, :effective_date=>time)
    measure.parameters.size.should eql(3)
    measure.parameters.should have_key(:effective_date)
    measure.parameters[:effective_date].should eql(time)
  end
  it 'should raise a RuntimeError if not passed all the parameters' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    lambda { QME::MapReduce::Builder.new(hash) }.should
      raise_error(RuntimeError, 'No value supplied for measure parameter: effective_date')
  end
  it 'should calculate the calculated dates correctly' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    date = Time.gm(2010, 9, 19).to_i
    measure = QME::MapReduce::Builder.new(hash, :effective_date=>date)
    measure.parameters[:earliest_encounter].should eql(date-QME::MapReduce::Builder::YEAR_IN_SECONDS)
  end
  it 'should produce valid JavaScript expressions for the query components' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    date = Time.gm(2010, 9, 19).to_i
    builder = QME::MapReduce::Builder.new(hash, :effective_date=>date)
    builder.numerator.should eql('(this.measures["0043"].vaccination==true)')
    builder.denominator.should eql('(this.measures["0043"].encounter>='+builder.parameters[:earliest_encounter].to_s+')')
    builder.population.should eql('(this.birthdate<='+builder.parameters[:earliest_birthdate].to_s+')')
    builder.exception.should eql('(false)')
    builder.map_function.should eql(MAP_FUNCTION)
    builder.reduce_function.should eql(QME::MapReduce::Builder::REDUCE_FUNCTION)
  end
  it 'should handle logical combinations' do
    hash = JSON.parse(COMPLEX_MEASURE_JSON)
    builder = QME::MapReduce::Builder.new(hash, {})
    builder.population.should eql('((this.measures["0043"].age>17)&&(this.measures["0043"].age<75)&&((this.measures["0043"].sex=="male")||(this.measures["0043"].sex=="female")))')
  end
end
