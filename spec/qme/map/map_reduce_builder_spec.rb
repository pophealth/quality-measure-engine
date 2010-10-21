describe QME::MapReduce::Builder do
  it 'should produce valid JavaScript expressions for the query components' do
    measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    hash = JSON.parse(measure_json)
    date = Time.now.to_i
    measure = QME::Measure.new(hash, :effective_date=>date)
    builder = QME::MapReduce::Builder.new(hash, :effective_date=>date)
    builder.numerator.should eql('measures.0043.vaccination==true')
    builder.denominator.should eql('measures.0043.encounter>='+measure.parameters[:earliest_encounter].value.to_s)
    builder.population.should eql('measures.0043.birthdate<='+measure.parameters[:earliest_birthdate].value.to_s)
    builder.exception.should eql('')
  end
end