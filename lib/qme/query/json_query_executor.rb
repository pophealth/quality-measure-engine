module QME
  module Query
    class JsonQueryExecutor
      def initialize(db)
        @db = db
      end

      def measure_def(measure_id)
        measures = @db.collection('measures')
        measures.find({'id'=> "#{measure_id}"}).to_a[0]
      end

      def measure_result(measure_id, parameter_values)
        jdb = JSONDocumentBuilder.new(measure_def(measure_id),
                                      parameter_values)

        collection = @db.collection('records')
        result = {}
        
        collection.find(jdb.numerator_query) do |cursor|
          result[:numerator] = cursor.count
        end
        
        collection.find(jdb.denominator_query) do |cursor|
          result[:denominator] = cursor.count
        end
        collection.find(jdb.initial_population_query) do |cursor|
          result[:population] = cursor.count
        end
        
        exclusions_query = jdb.exclusions_query
        if exclusions_query.empty?
          result[:exclusions] = 0
        else
          collection.find(exclusions_query) do |cursor|
            result[:exclusions] = cursor.count
          end
        end
        
        result
      end
    end
  end
end