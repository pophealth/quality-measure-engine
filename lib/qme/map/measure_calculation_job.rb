module QME
  module MapReduce
    class MeasureCalculationJob < Resque::JobWithStatus
      
      def perform
        map = QME::MapReduce::Executor.new(options['measure_id'], options['sub_id'], 'effective_date' => options['effective_date'])
        tick('Starting MapReduce')
        map.map_records_into_measure_groups
        tick('MapReduce complete')
        tick('Calculating group totals')
        result = map.count_records_in_measure_groups
        completed("#{options['measure_id']}#{options['sub_id']}: p#{result['population']}, d#{result['denominator']}, n#{result['numerator']}, e#{result['exclusions']}")
      end
    end
  end
end