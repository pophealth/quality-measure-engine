complex_measure_json = <<END_OF_COMPLEX_MEASURE
{
  "id": "0043",
  "name": "Pneumonia Vaccination Status for Older Adults",
  "steward": "NCQA",
  "population": {
    "$and": [
      {
        "category": "Patient Characteristic",
        "title": "Age > 17 before measure period",
        "query": {"age": {"$gt": 17}}
      },
      {
        "category": "Patient Characteristic",
        "title": "Age < 75 before measure period",
        "query": {"age": {"$lt": 75}}
      },
      {
        "$or": [
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

describe QME::MapReduce::Builder do
  it 'should produce valid JavaScript expressions for the query components' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    date = Time.now.to_i
    measure = QME::Measure.new(hash, :effective_date=>date)
    builder = QME::MapReduce::Builder.new(hash, :effective_date=>date)
    builder.numerator.should eql('(measures["0043"].vaccination==true)')
    builder.denominator.should eql('(measures["0043"].encounter>='+measure.parameters[:earliest_encounter].value.to_s+')')
    builder.population.should eql('(measures["0043"].birthdate<='+measure.parameters[:earliest_birthdate].value.to_s+')')
    builder.exception.should eql('(false)')
  end
  it 'should handle logical combinations' do
    hash = JSON.parse(complex_measure_json)
    measure = QME::Measure.new(hash, {})
    builder = QME::MapReduce::Builder.new(hash, {})
    builder.population.should eql('((measures["0043"].age>17)&&(measures["0043"].age<75)&&((measures["0043"].sex=="male")||(measures["0043"].sex=="female")))')
  end
end