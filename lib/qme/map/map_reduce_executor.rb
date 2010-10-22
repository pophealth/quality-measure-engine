# To change this template, choose Tools | Templates
# and open the template in the editor.

module QME
  module MapReduce
    class Executor
      def initialize(db)
        @db = db
      end
    end

    def execute(measure_id, parameter_values)
      measures = db.collection('measures')
      measure_def = measures.find({'id'=> "#{measure_id}"})
      measure = Builder.new(measure_def, parameter_values)

      records = db.collection('records')
      results = records.map_reduce(measure.map_function, measure.reduce_function)
      result = results.find.to_a[0]['value']

      puts " Population: #{result['i'].to_i}"
      puts "Denominator: #{result['d'].to_i}"
      puts "  Numerator: #{result['n'].to_i}"
      puts " Exceptions: #{result['e'].to_i}"
    end
  end
end
