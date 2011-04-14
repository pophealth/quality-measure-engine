module QME
  module MapReduce

    # Computes the value of quality measures based on the current set of patient
    # records in the database
    class Executor
    
      # Create a new Executor for the supplied database connection
      def initialize(db)
        @db = db
      end

      # Retrieve a measure definition from the database
      # @param [String] measure_id value of the measure's id field
      # @param [String] sub_id value of the measure's sub_id field, may be nil for measures with only a single numerator and denominator
      # @return [Hash] a JSON hash of the encoded measure
      def measure_def(measure_id, sub_id=nil)
        measures = @db.collection('measures')
        if sub_id
          measures.find_one({'id'=>measure_id, 'sub_id'=>sub_id})
        else
          measures.find_one({'id'=>measure_id})
        end
      end

      # Compute the specified measure
      # @param [String] measure_id value of the measure's id field
      # @param [String] sub_id value of the measure's sub_id field, may be nil for measures with only a single numerator and denominator
      # @param [Hash] parameter_values a hash of the measure parameter values. Keys may be either a String or Symbol
      # @return [Hash] a hash of the measure result with Symbol keys: population, denominator, numerator, antinumerator and exclusions whose 
      #                values are the count of patient records that meet the criteria for each component of the measure.
      def measure_result(measure_id, sub_id, parameter_values)
        result = cached_result(measure_id, sub_id, parameter_values)
        
        unless result
          result = generate_cache(measure_id, sub_id, parameter_values)
        end
        
        result
      end
      
      # Return a list of the measures in the database
      # @return [Hash] an hash of measure definitions
      def all_measures
        result = {}
        measures = @db.collection('measures')
        measures.find().each do |measure|
          id = measure['id']
          sub_id = measure['sub_id']
          measure_id = "#{id}#{sub_id}.json"
          result[measure_id] ||= measure
        end
        result
      end

      private

      def generate_cache(measure_id, sub_id, parameter_values)
        cache_measure_patients(measure_id, sub_id, parameter_values)
        cache_measure_result(measure_id, sub_id, parameter_values)
      end

      def cached_result(measure_id, sub_id, parameter_values)
        cache = @db.collection("query_cache")
        query = {:measure_id => measure_id, :sub_id => sub_id, 
                 :effective_date => parameter_values['effective_date']}
        cache.find_one(query)
      end

      def cache_measure_result(measure_id, sub_id, parameter_values)
        patient_cache = @db.collection('patient_cache')
        query = {'value.measure_id' => measure_id, 'value.sub_id' => sub_id, 
                 'value.effective_date' => parameter_values['effective_date']}
        result = {:measure_id => measure_id, :sub_id => sub_id, 
                  :effective_date => parameter_values['effective_date']}
        
        %w(population denominator numerator antinumerator exclusions).each do |measure_group|
          patient_cache.find(query.merge("value.#{measure_group}" => true)) do |cursor|
            result[measure_group] = cursor.count
          end
        end
        
        @db.collection("query_cache").save(result)
        
        result
      end

      # Private method to cache the patient record for a particular measure and effective time.
      # This also caches whether they are part of the denominator, numerator, etc. which will be used for sorting.
      # @param [String] measure_id value of the measure's id field
      # @param [String] sub_id value of the measure's sub_id field, may be nil for measures with only a single numerator and denominator
      # @param [Hash] parameter_values a hash of the measure parameter values. Keys may be either a String or Symbol
      def cache_measure_patients(measure_id, sub_id, parameter_values)
        patient_cache = @db.collection('patient_cache')
        patient_cache.remove(:measure_id => measure_id, :sub_id => sub_id, 
                             :effective_date => parameter_values['effective_date'])
        
        measure = Builder.new(@db, measure_def(measure_id, sub_id), parameter_values)
        records = @db.collection('records')
        records.map_reduce(measure.map_function, "function(key, values){return values;}", :out => {:reduce => 'patient_cache'}, :finalize => measure.finalize_function)
      end
    end
  end
end
