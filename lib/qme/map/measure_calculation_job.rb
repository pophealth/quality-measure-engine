module QME
  module MapReduce
    # A delayed_job that allows for measure calculation by a delayed_job worker. Can be created as follows:
    #
    #     Delayed::Job.enqueue QME::MapRedude::MeasureCalculationJob.new(:measure_id => '0221', :sub_id => 'a', :effective_date => 1291352400, :test_id => xyzzy)
    #
    # MeasureCalculationJob will check to see if a measure has been calculated before running the calculation. It does
    # this by creating a QME::QualityReport and asking if it has been calculated. If so, it will complete the job without
    # running the MapReduce job.
    #
    # When a measure needs calculation, the job will create a QME::MapReduce::Executor and interact with it to calculate
    # the report.
    class MeasureCalculationJob
      attr_accessor :test_id, :measure_id, :sub_id, :effective_date, :filters

      def initialize(options)
        @test_id = options['test_id']
        @measure_id = options['measure_id']
        @sub_id = options['sub_id']
        @effective_date = options['effective_date']
        @filters = options['filters']
      end
      
      def perform
        bson_test_id = @test_id ? Moped::BSON::ObjectId(@test_id) : nil
        qr = QualityReport.new(@measure_id, @sub_id, 'effective_date' => @effective_date, 
                               'test_id' => bson_test_id, 'filters' => @filters)
        if qr.calculated?
          completed("#{@measure_id}#{@sub_id} has already been calculated")
        else
          map = QME::MapReduce::Executor.new(@measure_id, @sub_id, 'effective_date' => @effective_date,
                                             'test_id' => bson_test_id, 'filters' => @filters, 
                                             'start_time' => Time.now.to_i)

          if !qr.patients_cached?
            tick('Starting MapReduce')
            map.map_records_into_measure_groups
            tick('MapReduce complete')
          end
          
          tick('Calculating group totals')
          result = map.count_records_in_measure_groups
          completed("#{@measure_id}#{@sub_id}: p#{result['population']}, d#{result['denominator']}, n#{result['numerator']}, excl#{result['exclusions']}, excep#{result['denexcep']}")
        end
      end

      def completed(message)
        
      end

      def tick(message)
        
      end
    end
  end
end