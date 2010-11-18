describe QME::MapReduce::Executor do

  before do
    db_host = nil
    if ENV['TEST_DB_HOST']
      db_host = ENV['TEST_DB_HOST']
    else
      db_host = 'localhost'
    end
    @db = Mongo::Connection.new(db_host, 27017).db('test')
    @measures = Dir.glob('measures/*')
  end
  
  it 'should produce the expected results for each measure' do
    print "\n"
    @measures.each do |dir|
      # load db with measure and sample patient records
      files = Dir.glob(File.join(dir,'*.json'))
      files.should have(1).items
      measure_file = files[0]
      files = Dir.glob(File.join(dir,'*.js'))
      files.should have_at_most(1).items
      map_file = files[0]
      patient_files = Dir.glob(File.join(dir, 'patients', '*.json'))
      patient_files.should have_at_least(1).items

      measure = JSON.parse(File.read(measure_file))
      measure_id = measure['id']
      puts "Validating measure #{measure_id}"
      if map_file
        map_fn = File.read(map_file)
        measure['map_fn'] = map_fn
      end
      
      @db.drop_collection('measures')
      @db.drop_collection('records')
      measure_collection = @db.create_collection('measures')
      record_collection = @db.create_collection('records')
      measure_collection.save(measure)
      patient_files.each do |patient_file|
        patient = JSON.parse(File.read(patient_file))
        record_collection.save(patient)
      end
      
      # load expected results
      result_file = File.join(dir, 'result', 'result.json')
      expected = JSON.parse(File.read(result_file))
      
      # evaulate measure using Map/Reduce and validate results
      executor = QME::MapReduce::Executor.new(@db)
      result = executor.measure_result(measure_id, 'effective_date'=>Time.gm(2010, 9, 19).to_i)
      result[:population].should eql(expected['initialPopulation'])
      result[:numerator].should eql(expected['numerator'])
      result[:denominator].should eql(expected['denominator'])
      result[:exclusions].should eql(expected['exclusions'])
      puts " - done"
    end
  end
  
end
