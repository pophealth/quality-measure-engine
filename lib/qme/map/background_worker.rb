module QME
  module MapReduce
    class BackgroundWorker
      @queue = :measure_result_caching
      
      def self.perform(measure_id, sub_id, effective_date)
        db_host = ENV['TEST_DB_HOST'] || 'localhost'
        db_port = ENV['TEST_DB_PORT'] ? ENV['TEST_DB_PORT'].to_i : 27017
        db_name = ENV['DB_NAME'] || 'test'
        
        db =  Mongo::Connection.new(db_host, db_port).db(db_name)
        
        map = QME::MapReduce::Executor.new(db)
        result = map.measure_result(measure_id, sub_id, 'effective_date' => effective_date)
        puts "#{measure_id}#{sub_id}: p#{result['population']}, d#{result['denominator']}, n#{result['numerator']}, e#{result['exclusions']}"
      end
    end
  end
end