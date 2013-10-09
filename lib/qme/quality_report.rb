module QME
  
  class QualityReportResult
    include Mongoid::Document
    include Mongoid::Timestamps

    field :population_ids, type: Hash
    field :IPP, type: Integer
    field :DENOM, type: Integer
    field :NUMER, type: Integer
    field :antinumerator, type: Integer
    field :DENEX, type: Integer
    field :DENEXCEP, type: Integer
    field :MSRPOPL, type: Integer
    field :OBSERV, type: Float
    field :supplemental_data, type: Hash

    embedded_in :quality_report, inverse_of: :result
  end
  # A class that allows you to create and obtain the results of running a
  # quality measure against a set of patient records.
  class QualityReport
    
    include Mongoid::Document
    include Mongoid::Timestamps
    store_in collection: 'query_cache'

    field :nqf_id, type: String
    field :npi, type: String
    field :calculation_time, type: Time 
    field :status, type: Hash, default: {"state" => "unkown", "log" => []}
    field :measure_id, type: String
    field :sub_id, type: String
    field :test_id
    field :effective_date, type: Integer
    field :filters, type: Hash
    embeds_one :result, class_name: "QME::QualityReportResult", inverse_of: :quality_report


    POPULATION = 'IPP'
    DENOMINATOR = 'DENOM'
    NUMERATOR = 'NUMER'
    EXCLUSIONS = 'DENEX'
    EXCEPTIONS = 'DENEXCEP'
    MSRPOPL = 'MSRPOPL'
    OBSERVATION = 'OBSERV'
    ANTINUMERATOR = 'antinumerator'
    CONSIDERED = 'considered'

    RACE = 'RACE'
    ETHNICITY = 'ETHNICITY'
    SEX ='SEX'
    POSTAL_CODE = 'POSTAL_CODE'
    PAYER   = 'PAYER'

   
    
    # Removes the cached results for the patient with the supplied id and
    # recalculates as necessary
    def self.update_patient_results(id)

      
      # TODO: need to wait for any outstanding calculations to complete and then prevent
      # any new ones from starting until we are done.

      # drop any cached measure result calculations for the modified patient
     QME::PatientCache.where('value.medical_record_id' => id).destroy()
      
      # get a list of cached measure results for a single patient
      sample_patient = QME::PatientCache.where({}).first
      if sample_patient
        cached_results = QME::PatientCache.where({'value.patient_id' => sample_patient['value']['patient_id']})
        
        # for each cached result (a combination of measure_id, sub_id, effective_date and test_id)
        cached_results.each do |measure|
          # recalculate patient_cache value for modified patient
          value = measure['value']
          map = QME::MapReduce::Executor.new(value['measure_id'], value['sub_id'],
            'effective_date' => value['effective_date'], 'test_id' => value['test_id'])
          map.map_record_into_measure_groups(id)
        end
      end
      
      # remove the query totals so they will be recalculated using the new results for
      # the modified patient
      self.destroy_all
    end

   


    def self.find_or_create(measure_id, sub_id, parameter_values)
      @parameter_values = parameter_values
      @parameter_values[:filters] = self.normalize_filters(@parameter_values[:filters])
      query = {measure_id: measure_id, sub_id: sub_id}
      query.merge! @parameter_values
      self.find_or_create_by(query)
    end
    
    # Determines whether the quality report has been calculated for the given
    # measure and parameters
    # @return [true|false]
    def calculated?
      self.status["state"] == "completed"
    end

    # Determines whether the patient mapping for the quality report has been
    # completed
    def patients_cached?
      ! patient_result().nil?
    end
    
    # Kicks off a background job to calculate the measure
    # @return a unique id for the measure calculation job
    def calculate(parameters, asynchronous=true)
      
      options = {'quality_report_id' => self.id}
      
      options.merge! parameters
     
      if (asynchronous)
        job = Delayed::Job.enqueue(QME::MapReduce::MeasureCalculationJob.new(options))
        self.status["state"] = "queued"
        job._id
      else
        mcj = QME::MapReduce::MeasureCalculationJob.new(options)
        mcj.perform
      end
    end
    
    
    # make sure all filter id arrays are sorted
    def self.normalize_filters(filters)
      filters.each {|key, value| value.sort_by! {|v| (v.is_a? Hash) ? "#{v}" : v} if value.is_a? Array} unless filters.nil?
    end
    
    def patient_result(patient_id = nil)
      query = {'value.measure_id' => self.measure_id, 'value.sub_id' => self.sub_id, 
               'value.effective_date' => self.effective_date,
               'value.test_id' => self['test_id']}
      if patient_id
        query['value.medical_record_id'] = patient_id
      end
       QME::PatientCache.where(query).first()
    end
    
  end
end