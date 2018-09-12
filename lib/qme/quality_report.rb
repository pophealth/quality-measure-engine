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
    include Mongoid::Attributes::Dynamic
    store_in collection: 'query_cache'

    field :nqf_id, type: String
    field :npi, type: String
    field :calculation_time, type: Time
    field :status, type: Hash, default: {"state" => "unknown", "log" => []}
    field :measure_id, type: String
    field :sub_id, type: String
    field :test_id
    field :effective_date, type: Integer
    field :filters, type: Hash
    field :prefilter, type: Hash
    embeds_one :result, class_name: "QME::QualityReportResult", inverse_of: :quality_report
    index "measure_id" => 1
    index "sub_id" => 1
    index "filters.provider_performances.provider_id" => 1

    POPULATION = 'IPP'
    DENOMINATOR = 'DENOM'
    NUMERATOR = 'NUMER'
    EXCLUSIONS = 'DENEX'
    EXCEPTIONS = 'DENEXCEP'
    MSRPOPL = 'MSRPOPL'
    MSRPOPLEX = 'MSRPOPLEX'
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

    def self.queue_staged_rollups(measure_id,sub_id,effective_date)
     query = Mongoid.default_client["rollup_buffer"].find({measure_id: measure_id, sub_id: sub_id, effective_date: effective_date})
     query.each do |options|
        if QME::QualityReport.where("_id" => options["quality_report_id"]).count == 1
           QME::QualityReport.enque_job(options,:rollup)
        end
     end
     query.delete_many
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
      !QME::QualityReport.where({measure_id: self.measure_id,sub_id:self.sub_id, effective_date: self.effective_date, test_id: self.test_id, "status.state" => "completed" }).first.nil?
    end


     # Determines whether the patient mapping for the quality report has been
    # queued up by another quality report or if it is currently running
    def calculation_queued_or_running?
      !QME::QualityReport.where({measure_id: self.measure_id,sub_id:self.sub_id, effective_date: self.effective_date, test_id: self.test_id }).nin("status.state" =>["unknown","stagged"]).first.nil?
    end

    # Kicks off a background job to calculate the measure
    # @return a unique id for the measure calculation job
    def calculate(parameters, asynchronous=true)

      options = {'quality_report_id' => self.id}
      options.merge! parameters || {}

      if self.status["state"] == "completed" && !options["recalculate"]
        return self
      end

      self.status["state"] = "queued"
      if (asynchronous)
        options[:asynchronous] = true
        if patients_cached?
          QME::QualityReport.enque_job(options,:rollup)
        elsif calculation_queued_or_running?
          self.status["state"] = "stagged"
          self.save
          options.merge!( {measure_id: self.measure_id, sub_id: self.sub_id, effective_date: self.effective_date })
          Mongoid.default_client["rollup_buffer"].insert_one(options)
        else
          # queue the job for calculation
          QME::QualityReport.enque_job(options,:calculation)
        end
      else
        mcj = QME::MapReduce::MeasureCalculationJob.new(options)
        mcj.perform
      end
    end

    def patient_results
     puts "#############patient results from qme################"
     ex = QME::MapReduce::Executor.new(self.measure_id,self.sub_id, self.attributes)
     puts "################calling patient cache matcher######################" 
     puts patient_cache_matcher.to_s
     puts "################end patient cache matcher######################" 
     QDM::IndividualResult.where(patient_cache_matcher)
    end

    def measure
      QME::QualityMeasure.where({"hqmf_id"=>self.measure_id, "sub_id" => self.sub_id}).first
    end

    # make sure all filter id arrays are sorted
    def self.normalize_filters(filters)
      filters.each {|key, value| value.sort_by! {|v| (v.is_a? Hash) ? "#{v}" : v} if value.is_a? Array} unless filters.nil?
    end

    def patient_result(patient_id = nil)
      query = patient_cache_matcher
      if patient_id
        query['value.medical_record_id'] = patient_id
      end
       QME::PatientCache.where(query).first()
    end


    def patient_cache_matcher
      puts "#############in patient cache matcher######################"
      match = {'value.measure_id' => self.measure_id,
               'value.effective_date'   => self.effective_date,
               'value.test_id'          => test_id}
=begin
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
        if (filters['providers'] && filters['providers'].size > 0)
          providers = filters['providers'].map { |pv| BSON::ObjectId.from_string(pv) }
          match['value.provider_performances.provider_id'] = {'$in' => providers}
        end
        if (filters['languages'] && filters['languages'].size > 0)
          match["value.languages"] = {'$in' => filters['languages']}
        end
      end
=end
      match
    end

    protected

     # In the older version of QME QualityReport was not treated as a persisted object. As
     # a result anytime you wanted to get the cached results for a calculation you would create
     # a new QR object which would then go to the db and see if the calculation was performed or
     # not yet and then return the results.  Now that QR objects are persisted you need to go through
     # the find_or_create by method to ensure that duplicate entries are not being created.  Protecting
     # this method causes an exception to be thrown for anyone attempting to use this version of QME with the
     # sematics of the older version to highlight the issue.
    def initialize(attrs = nil)
      super(attrs)
    end

    def self.enque_job(options,queue)
      Delayed::Job.enqueue(QME::MapReduce::MeasureCalculationJob.new(options), {queue: queue})
    end
  end
end
