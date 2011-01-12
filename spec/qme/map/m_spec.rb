require File.joint(File.dirname(_FILE__),'../../lib/tasks/database_loader')

describe QME::MapReduce::Executor do

  before do
    @loader = QME::Database::Loader.new('test')
    @measures = Dir.glob('measures/*')
  end
  
  it 'should produce the expected results for each measure' do
    print "\n"
    @measures.each do |dir|
      puts "Parsing #{dir}"

      @loader.drop_collection('measures')
      @loader.drop_collection('records')
      @loader.drop_collection('query_cache')
      
      # load db with measure
      measures = @loader.save_measure(dir, 'measures')
      
      # load db with sample patient records
      patient_files = Dir.glob(File.join(dir, 'patients', '*.json'))
      patient_files.each do |patient_file|
        patient = JSON.parse(File.read(patient_file))
        @loader.save('records', patient)
      end
        
      # load expected results
      result_file = File.join(dir, 'result', 'result.json')
      expected = JSON.parse(File.read(result_file))
      
      # evaulate measure using Map/Reduce and validate results
      executor = QME::MapReduce::Executor.new(@loader.get_db)
      measures.each do |measure|
        measure_id = measure['id']
        sub_id = measure['sub_id']
        puts "Validating measure #{measure_id}#{sub_id}"
        result = executor.measure_result(measure_id, sub_id,'effective_date'=>Time.gm(2010, 9, 19).to_i)
        if expected['initialPopulation'] == nil
          # multiple results for multi numerator/denominator measure
          # loop through list of results to find the matching one
          expected['results'].each do |expect|
            if expect['id'].eql?(measure_id) && (sub_id==nil || expect['sub_id'].eql?(sub_id))
              result[:population].should eql(expect['initialPopulation'])
              result[:numerator].should eql(expect['numerator'])
              result[:denominator].should eql(expect['denominator'])
              result[:exclusions].should eql(expect['exclusions'])
              (result[:numerator]+result[:antinumerator]).should eql(expect['denominator'])
              break
            end
          end
        else
          result[:population].should eql(expected['initialPopulation'])
          result[:numerator].should eql(expected['numerator'])
          result[:denominator].should eql(expected['denominator'])
          result[:exclusions].should eql(expected['exclusions'])
          (result[:numerator]+result[:antinumerator]).should eql(expected['denominator'])
        end
      end
      puts ' - done'
    end
  end
  
end
