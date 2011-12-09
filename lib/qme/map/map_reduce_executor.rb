module QME

  module MapReduce

    # Computes the value of quality measures based on the current set of patient
    # records in the database
    class Executor

      include DatabaseAccess

      # Create a new Executor for a specific measure, effective date and patient population.
      # @param [String] measure_id the measure identifier
      # @param [String] sub_id the measure sub-identifier or null if the measure is single numerator
      # @param [Hash] parameter_values a hash that may contain the following keys: 'effective_date' the measurement period end date, 'test_id' an identifier for a specific set of patients
      def initialize(measure_id, sub_id, parameter_values)
        @measure_id = measure_id
        @sub_id = sub_id
        @parameter_values = parameter_values
        determine_connection_information
      end

      # Examines the patient_cache collection and generates a total of all groups
      # for the measure. The totals are placed in a document in the query_cache
      # collection.
      # @return [Hash] measure groups (like numerator) as keys, counts as values
      def count_records_in_measure_groups
        patient_cache = get_db.collection('patient_cache')
        query = {'value.measure_id' => @measure_id, 'value.sub_id' => @sub_id,
                 'value.effective_date' => @parameter_values['effective_date'],
                 'value.test_id' => @parameter_values['test_id']}
        
        query.merge!(filter_parameters)
        
        result = {:measure_id => @measure_id, :sub_id => @sub_id, 
                  :effective_date => @parameter_values['effective_date'],
                  :test_id => @parameter_values['test_id'], :filters => @parameter_values['filters']}
        
        aggregate = patient_cache.group({cond: query, 
                                           initial: {population: 0, denominator: 0, numerator: 0, antinumerator: 0,  exclusions: 0, considered: 0}, 
                                           reduce: "function(record,sums) {
                                                      for (var key in sums) {
                                                        if (!record['value']['manual_exclusion'])
                                                          sums[key] += (record['value'][key] || key == 'considered') ? 1 : 0
                                                      }
                                                    }"}).first
        
        aggregate ||= {population: 0, denominator: 0, numerator: 0, antinumerator: 0,  exclusions: 0}
        aggregate.each {|key, value| aggregate[key] = value.to_i}
        result.merge!(aggregate)
        
# need to time the old way agains the single query to verify that the single query is more performant        
#        %w(population denominator numerator antinumerator exclusions).each do |measure_group|
#          patient_cache.find(query.merge("value.#{measure_group}" => true)) do |cursor|
#            result[measure_group] = cursor.count
#          end
#        end

        result.merge!(execution_time: (Time.now.to_i - @parameter_values['start_time'].to_i)) if @parameter_values['start_time']

        get_db.collection("query_cache").save(result, safe: true)
        result
      end

      # This method runs the MapReduce job for the measure which will create documents
      # in the patient_cache collection. These documents will state the measure groups
      # that the record belongs to, such as numerator, etc.
      def map_records_into_measure_groups
        qm = QualityMeasure.new(@measure_id, @sub_id)
        measure = Builder.new(get_db, qm.definition, @parameter_values)
        records = get_db.collection('records')
        records.map_reduce(measure.map_function, "function(key, values){return values;}",
                           :out => {:reduce => 'patient_cache'}, 
                           :finalize => measure.finalize_function,
                           :query => {:test_id => @parameter_values['test_id']})
        apply_manual_exclusions
      end
      
      # This method runs the MapReduce job for the measure and a specific patient.
      # This will create a document in the patient_cache collection. This document
      # will state the measure groups that the record belongs to, such as numerator, etc.
      def map_record_into_measure_groups(patient_id)
        qm = QualityMeasure.new(@measure_id, @sub_id)
        measure = Builder.new(get_db, qm.definition, @parameter_values)
        records = get_db.collection('records')
        records.map_reduce(measure.map_function, "function(key, values){return values;}",
                           :out => {:reduce => 'patient_cache'}, 
                           :finalize => measure.finalize_function,
                           :query => {:patient_id => patient_id, :test_id => @parameter_values['test_id']})
        apply_manual_exclusions
      end
      
      # This records collects the set of manual exclusions from the manual_exclusions collections
      # and sets a flag in each cached patient result for patients that have been excluded from the
      # current measure
      def apply_manual_exclusions
        exclusions = get_db.collection('manual_exclusions').find({'measure_id'=>@measure_id, 'sub_id'=>@sub_id}).to_a.map do |exclusion|
          exclusion['medical_record_id']
        end
        get_db.collection('patient_cache').update(
          {'value.measure_id'=>@measure_id, 'value.sub_id'=>@sub_id, 'value.medical_record_id'=>{'$in'=>exclusions} },
          {'$set'=>{'value.manual_exclusion'=>true}}, :multi=>true)
      end

      def filter_parameters
        results = {}
        conditions = []
        if(filters = @parameter_values['filters'])
          if (filters['providers'] && filters['providers'].size > 0)
            providers = filters['providers'].map {|provider_id| BSON::ObjectId(provider_id) if provider_id }
            conditions << provider_queries(providers, @parameter_values['effective_date'])
          end
          if (filters['races'] && filters['races'].size > 0)
            conditions << {'value.race.code' => {'$in' => filters['races']}}
          end
          if (filters['ethnicities'] && filters['ethnicities'].size > 0)
            conditions << {'value.ethnicity.code' => {'$in' => filters['ethnicities']}}
          end
          if (filters['genders'] && filters['genders'].size > 0)
            conditions << {'value.gender' => {'$in' => filters['genders']}}
          end
        end
        results.merge!({'$and'=>conditions}) if conditions.length > 0
        results
      end
      
      def provider_queries(provider_ids, effective_date)
       {'$or' => [provider_query(provider_ids, effective_date,effective_date), provider_query(provider_ids, nil,effective_date), provider_query(provider_ids, effective_date,nil)]}
      end
      
      def provider_query(provider_ids, start_before, end_after)
        {'value.provider_performances' => {'$elemMatch' => {'provider_id' => {'$in' => provider_ids}, 'start_date'=> {'$lt'=>start_before}, 'end_date'=> {'$gt'=>end_after} } }}
      end
    end
  end
end
