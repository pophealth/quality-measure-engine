module QME
  class ManualExclusion
    include Mongoid::Document
    store_in collection: 'manual_exclusions'
    field :measure_id, type: String
    field :sub_id, type: String
    field :medical_record_id, type: String


    def self.apply_manual_exclusions(measure_id, sub_id)
      mids = where({measure_id: measure_id, sub_id: sub_id}).collect {|me| me.medical_record_id}
      QME::PatientCache.where({'value.measure_id'=>@measure_id, 'value.sub_id'=>@sub_id, 'value.medical_record_id'=>{'$in'=>mids} })
          .update_all({'$set'=>{'value.manual_exclusion'=>true}})
    end

  end
end

