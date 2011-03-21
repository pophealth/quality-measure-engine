describe QME::MongoHelpers do
  before do
    @db = QME::Database::Loader.new('test').get_db
  end
  
  it 'Should set up the JavaScript environment' do
    QME::MongoHelpers.initialize_javascript_frameworks(@db)
    result = @db.eval('return _.map([1, 2, 3], function(num){ return num * 3; });')
    result[0].should == 3
    result[1].should == 6
  end
end