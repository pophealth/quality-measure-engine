describe QME::Query::JSONDocumentBuilder do

  before do
    raw_measure_json = File.read('measures/0043/0043_NQF_PneumoniaVaccinationStatusForOlderAdults.json')
    @measure_json = JSON.parse(raw_measure_json)
    raw_measure_json = File.read('fixtures/complex_measure.json')
    @complex_measure_json = JSON.parse(raw_measure_json)
  end

  it 'should calculate dates for a measure' do
    jdb = QME::Query::JSONDocumentBuilder.new(@measure_json)
    jdb.parameters = {:effective_date => 1287685441}
    jdb.calculate_dates
    jdb.calculated_dates['earliest_birthdate'].should == -762154559
  end

  it 'should create a query for a simple measure' do
    jdb = QME::Query::JSONDocumentBuilder.new(@measure_json, {:effective_date => 1287685441})
    query_hash = jdb.create_query(@measure_json['denominator'])
    query_hash.size.should be 1
    query_hash['measures.0043.encounter'].should_not be_nil
    query_hash['measures.0043.encounter']['$gte'].should == 1256149441
  end

  it 'should properly transform a property name' do
    jdb = QME::Query::JSONDocumentBuilder.new(@measure_json, {:effective_date => 1287685441})
    jdb.transform_query_property('birthdate').should == 'birthdate'
    jdb.transform_query_property('foo').should == 'measures.0043.foo'
  end

  it 'should properly process a query leaf when it is an expression' do
    jdb = QME::Query::JSONDocumentBuilder.new(@measure_json, {:effective_date => 1287685441})
    args = {}
    jdb.process_query({"encounter" => {"_gte" => "@earliest_encounter"}}, args)
    args.size.should be 1
    args['measures.0043.encounter'].should_not be_nil
    args['measures.0043.encounter']['$gte'].should == 1256149441
  end

  it 'should properly process a query leaf when it is a value' do
    jdb = QME::Query::JSONDocumentBuilder.new(@measure_json, {:effective_date => 1287685441})
    args = {}
    jdb.process_query({"encounter" => 'splat'}, args)
    args.size.should be 1
    args['measures.0043.encounter'].should_not be_nil
    args['measures.0043.encounter'].should == 'splat'
  end

  it 'should create a query for a complex measure' do
    jdb = QME::Query::JSONDocumentBuilder.new(@complex_measure_json)
    query_hash = jdb.create_query(@complex_measure_json['population'])
    query_hash['measures.0043.age']['$gt'].should == 17
    query_hash['measures.0043.age']['$lt'].should == 75
    query_hash['$or'].should have(2).items
  end
end
