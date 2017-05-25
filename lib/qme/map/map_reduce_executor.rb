module QME

  module MapReduce

    # Computes the value of quality measures based on the current set of patient
    # records in the database
    class Executor

      include DatabaseAccess
      SUPPLEMENTAL_DATA_ELEMENTS = {QME::QualityReport::RACE => "$value.race.code",
                                    QME::QualityReport::ETHNICITY => "$value.ethnicity.code",
                                    QME::QualityReport::SEX => "$value.gender",
                                    QME::QualityReport::PAYER => "$value.payer.code"}
      # Create a new Executor for a specific measure, effective date and patient population.
      # @param [String] measure_id the measure identifier
      # @param [String] sub_id the measure sub-identifier or null if the measure is single numerator
      # @param [Hash] parameter_values a hash that may contain the following keys: 'effective_date' the measurement period end date, 'test_id' an identifier for a specific set of patients
      def initialize(measure_id,sub_id, parameter_values)

        @measure_id = measure_id
        @sub_id =sub_id

        @parameter_values = parameter_values
        q_filter = {hqmf_id: @measure_id,sub_id: @sub_id}
        if @parameter_values.keys.index("bundle_id")
          q_filter["bundle_id"] == @parameter_values['bundle_id']
          @bundle_id = @parameter_values['bundle_id']
        end
        @measure_def = QualityMeasure.where(q_filter).first
      end

      def build_query
        pipeline = []

        filters = @parameter_values["filters"]


        match = {'value.measure_id' => @measure_id,
                 'value.sub_id'           => @sub_id,
                 'value.effective_date'   => @parameter_values['effective_date'],
                 'value.test_id'          => @parameter_values['test_id'],
                 'value.manual_exclusion' => {'$in' => [nil, false]}}

        if(filters)
          if (filters['races'] && filters['races'].size > 0)
            match['value.race.code'] = {'$in' => filters['races']}
          end
          if (filters['ethnicities'] && filters['ethnicities'].size > 0)
            match['value.ethnicity.code'] = {'$in' => filters['ethnicities']}
          end
          if (filters['genders'] && filters['genders'].size > 0)
            match['value.gender'] = {'$in' => filters['genders']}
          end
          if (filters['patients'] && filters['patients'].size > 0)
            match['value.patient_id'] = {'$in' => filters['patients']}
          end
          if (filters['providers'] && filters['providers'].size > 0)
            providers = filters['providers'].map { |pv| {'providers' => BSON::ObjectId.from_string(pv) } }
            pipeline.concat [{'$project' => {'value' => 1, 'providers' => "$value.provider_performances.provider_id"}},
                             {'$unwind' => '$providers'},
                             {'$match' => {'$or' => providers}},
                             {'$group' => {"_id" => "$_id", "value" => {"$first" => "$value"}}}]
          end
          if (filters['languages'] && filters['languages'].size > 0)
            languages = filters['languages'].map { |l| {'languages' => l } }
            pipeline.concat  [{'$project' => {'value' => 1, 'languages' => "$value.languages"}},
                              {'$unwind' => "$languages"},
                              {'$project' => {'value' => 1, 'languages' => {'$substr' => ['$languages', 0, 2]}}},
                              {'$match' => {'$or' => languages}},
                              {'$group' => {"_id" => "$_id", "value" => {"$first" => "$value"}}}]
          end
        end

        pipeline.unshift({'$match' => match})

        pipeline
      end


      #Calculate all of the supoplemental data elements
      def calculate_supplemental_data_elements

        match = {'value.measure_id' => @measure_id,
                 'value.sub_id'           => @sub_id,
                 'value.effective_date'   => @parameter_values['effective_date'],
                 'value.test_id'          => @parameter_values['test_id'],
                 'value.manual_exclusion' => {'$in' => [nil, false]}}

        keys = @measure_def.population_ids.keys - [QME::QualityReport::OBSERVATION, "stratification"]
        supplemental_data = Hash[*keys.map{|k| [k,{QME::QualityReport::RACE => {},
                                                   QME::QualityReport::ETHNICITY => {},
                                                   QME::QualityReport::SEX => {},
                                                   QME::QualityReport::PAYER => {}}]}.flatten]                                      
        keys.each do |pop_id|
          pline = build_query

          _match = pline[0]["$match"]
          _match["value.#{pop_id}"] = {"$gt" => 0}
          SUPPLEMENTAL_DATA_ELEMENTS.each_pair do |supp_element,location|
            group1 = {"$group" => { "_id" => { "id" => "$_id", "val" => location}}}
            group2 = {"$group" => {"_id" => "$_id.val", "val" =>{"$sum" => 1} }}
            pipeline = pline.clone
            pipeline << group1
            pipeline << group2

            aggregate = get_db.command(:aggregate => 'patient_cache', :pipeline => pipeline)
            aggregate_document = aggregate.documents[0]
            v = {}
            (aggregate_document["result"] || []).each  do |entry|
              code  = entry["_id"].nil? ? "UNK" : entry["_id"]
              v[code] = entry["val"]
            end
            supplemental_data[pop_id] ||= {}
            supplemental_data[pop_id][supp_element] = v
           end
        end
        supplemental_data
      end


      # Examines the patient_cache collection and generates a total of all groups
      # for the measure. The totals are placed in a document in the query_cache
      # collection.
      # @return [Hash] measure groups (like numerator) as keys, counts as values
      def count_records_in_measure_groups
        pipeline = build_query

        pipeline << {'$group' => {
          "_id" => "$value.measure_id", # we don't really need this, but Mongo requires that we group
          QME::QualityReport::POPULATION => {"$sum" => "$value.#{QME::QualityReport::POPULATION}"},
          QME::QualityReport::DENOMINATOR => {"$sum" => "$value.#{QME::QualityReport::DENOMINATOR}"},
          QME::QualityReport::NUMERATOR => {"$sum" => "$value.#{QME::QualityReport::NUMERATOR}"},
          QME::QualityReport::ANTINUMERATOR => {"$sum" => "$value.#{QME::QualityReport::ANTINUMERATOR}"},
          QME::QualityReport::EXCLUSIONS => {"$sum" => "$value.#{QME::QualityReport::EXCLUSIONS}"},
          QME::QualityReport::EXCEPTIONS => {"$sum" => "$value.#{QME::QualityReport::EXCEPTIONS}"},
          QME::QualityReport::MSRPOPL => {"$sum" => "$value.#{QME::QualityReport::MSRPOPL}"},
          QME::QualityReport::MSRPOPLEX => {"$sum" => "$value.#{QME::QualityReport::MSRPOPLEX}"},
          QME::QualityReport::CONSIDERED => {"$sum" => 1}
        }}

        aggregate = get_db.command(:aggregate => 'patient_cache', :pipeline => pipeline)
        aggregate_document = aggregate.documents[0]
        if !aggregate.successful?
          raise RuntimeError, "Aggregation Failed"
        elsif aggregate_document['result'].size !=1
           aggregate_document['result'] =[{"defaults" => true,
                                 QME::QualityReport::POPULATION => 0,
                                 QME::QualityReport::DENOMINATOR => 0,
                                 QME::QualityReport::NUMERATOR =>0,
                                 QME::QualityReport::ANTINUMERATOR => 0,
                                 QME::QualityReport::EXCLUSIONS => 0,
                                 QME::QualityReport::EXCEPTIONS => 0,
                                 QME::QualityReport::MSRPOPL => 0,
                                 QME::QualityReport::MSRPOPLEX => 0,
                                 QME::QualityReport::CONSIDERED => 0}]
        end

        nqf_id = @measure_def.nqf_id || @measure_def['id']
        result = QME::QualityReportResult.new
        result.population_ids=@measure_def.population_ids


        if @measure_def.continuous_variable
          aggregated_value = calculate_cv_aggregation
          result[QME::QualityReport::OBSERVATION] = aggregated_value
        end

        agg_result = aggregate_document['result'].first
        agg_result.reject! {|k, v| k == '_id'} # get rid of the group id the Mongo forced us to use
        # result['exclusions'] += get_db['patient_cache'].find(base_query.merge({'value.manual_exclusion'=>true})).count
        agg_result.merge!(execution_time: (Time.now.to_i - @parameter_values['start_time'].to_i)) if @parameter_values['start_time']
        agg_result.each_pair do |k,v|
          result[k]=v
        end
        result.supplemental_data = self.calculate_supplemental_data_elements
        result

      end

      # This method calculates the aggregated value for a CV measure.  It extracts all
      # the values for patients in the MSRPOPL and uses the aggregator to combine those
      # values into an aggregated value.  The currently supported aggregators are:
      #   MEDIAN
      #   MEAN
      def calculate_cv_aggregation
        cv_pipeline = build_query
        cv_pipeline.first['$match']["value.#{QME::QualityReport::MSRPOPL}"] = {'$gt'=>0}
        # Don't include patients that are in MSRPOPLEX
        #cv_pipeline.first['$match']["value.#{QME::QualityReport::MSRPOPLEX}"] = {'$lt'=>1}
        cv_pipeline << {'$unwind' => '$value.values'}
        cv_pipeline << {'$group' => {'_id' => '$value.values', 'count' => {'$sum' => 1}}}

        aggregate = get_db.command(:aggregate => 'patient_cache', :pipeline => cv_pipeline)
        aggregate_document = aggregate.documents[0]

        raise RuntimeError, "Aggregation Failed" if aggregate_document['ok'] != 1

        frequencies = {}
        aggregate_document['result'].each do |freq_count_pair|
          frequencies[freq_count_pair['_id']] = freq_count_pair['count']
        end
        QME::MapReduce::CVAggregator.send(@measure_def.aggregator.parameterize, frequencies)
      end


      # This method runs the MapReduce job for the measure which will create documents
      # in the patient_cache collection. These documents will state the measure groups
      # that the record belongs to, such as numerator, etc.
      def map_records_into_measure_groups(prefilter={})
        measure = Builder.new(get_db(), @measure_def, @parameter_values)
        get_db().command(:mapreduce => 'records',
                         :map => measure.map_function,
                         :reduce => "function(key, values){return values;}",
                         :out => {:reduce => 'patient_cache', :sharded => true},
                         :finalize => measure.finalize_function,
                         :query => prefilter)
        QME::ManualExclusion.apply_manual_exclusions(@measure_id,@sub_id)
      end

      # This method runs the MapReduce job for the measure and a specific patient.
      # This will create a document in the patient_cache collection. This document
      # will state the measure groups that the record belongs to, such as numerator, etc.
      def map_record_into_measure_groups(patient_id)
        measure = Builder.new(get_db(), @measure_def, @parameter_values)
        get_db().command(:mapreduce => 'records',
                         :map => measure.map_function,
                         :reduce => "function(key, values){return values;}",
                         :out => {:reduce => 'patient_cache', :sharded => true},
                         :finalize => measure.finalize_function,
                         :query => {:medical_record_number => patient_id, :test_id => @parameter_values["test_id"]})
        QME::ManualExclusion.apply_manual_exclusions(@measure_id,@sub_id)

      end

      # This method runs the MapReduce job for the measure and a specific patient.
      # This will *not* create a document in the patient_cache collection, instead the
      # result is returned directly.
      def get_patient_result(patient_id)
        measure = Builder.new(get_db(), @measure_def, @parameter_values)
        operation = get_db().command(:mapreduce => 'records',
                                  :map => measure.map_function,
                                  :reduce => "function(key, values){return values;}",
                                  :out => {:inline => true},
                                  # :raw => true,
                                  :query => {:medical_record_number => patient_id, :test_id => @parameter_values["test_id"]})


        raise operation.documents[0]['err'] if !operation.successful?
        return nil if operation.documents[0]['results'].empty?
        operation.documents[0]['results'][0]['value']
      end


    end
  end
end
