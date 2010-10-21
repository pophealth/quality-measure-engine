describe QME::Query::JSONDocumentBuilder do

  before do
    raw_measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    @measure_json = JSON.parse(raw_measure_json)
  end

  it 'should calculate dates for a measure' do
    jdb = QME::Query::JSONDocumentBuilder.new(@measure_json)
    jdb.parameters = {:effective_date => 1287685441}
    jdb.calculate_dates
    jdb.calculated_dates['earliest_birthdate'].should == -762154559
  end
end
