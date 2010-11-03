module QME
  module MapReduce
    class Executor
      def initialize(db)
        @db = db
      end

      def measure_def(measure_id)
        measures = @db.collection('measures')
        measures.find({'id'=> "#{measure_id}"}).to_a[0]
      end

      def measure_result(measure_id, parameter_values)
        
        measure = Builder.new(measure_def(measure_id), parameter_values)

        records = @db.collection('records')
        results = records.map_reduce(measure.map_function, measure.reduce_function)
        result = results.find.to_a[0]
        value = result['value']

        {
          :population=>value['i'].to_i,
          :denominator=> value['d'].to_i,
          :numerator=> value['n'].to_i,
          :exclusions=> value['e'].to_i
        }
      end
    end
  end
end
