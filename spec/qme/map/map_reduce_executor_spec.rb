describe QME::MapReduce::Executor do
  it 'should be able to get a query from the database' do
    db = Mongo::Connection.new('localhost', 27017).db('test')
    e = QME::MapReduce::Executor.new(db)
    
    r = e.execute('0043', :effective_date=>Time.gm(2010, 9, 19).to_i)
    
    r[:population].should eql(3)
    r[:numerator].should eql(1)
    r[:denominator].should eql(2)
    r[:exceptions].should eql(0)
  end
end