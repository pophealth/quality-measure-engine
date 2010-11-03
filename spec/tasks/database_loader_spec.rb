describe QME::Database::Loader do
  it 'should create 4 measure definitions for the fixture' do
    loader = QME::Database::Loader.new(nil)
    measures = loader.create_collection('fixtures/measure_collection/measure.col', 'fixtures/measure_collection/components')
    measures.size.should eql(4)
    measures[0]['sub_id'].should eql('a')
    measures[0]['denominator']['query']['value'].should eql(1)
    measures[0]['numerator']['query']['value'].should eql(1)
    measures[1]['sub_id'].should eql('b')
    measures[1]['denominator']['query']['value'].should eql(1)
    measures[1]['numerator']['query']['value'].should eql(2)
    measures[2]['sub_id'].should eql('c')
    measures[2]['denominator']['query']['value'].should eql(2)
    measures[2]['numerator']['query']['value'].should eql(1)
    measures[3]['sub_id'].should eql('d')
    measures[3]['denominator']['query']['value'].should eql(2)
    measures[3]['numerator']['query']['value'].should eql(2)
  end
end