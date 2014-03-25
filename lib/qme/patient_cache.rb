 module QME
  class PatientCache
    include Mongoid::Document
    include Mongoid::Timestamps
    store_in collection: 'patient_cache'
    index "value.last" => 1
    index "bundle_id" => 1
    embeds_one :value, class_name: "QME::PatientCacheValue", inverse_of: :patient_cache
  end

  class PatientCacheValue

    include Mongoid::Document

    embedded_in :patient_cache, inverse_of: :value

    field :filters, type: Hash
    field :manual_exclusion, type: Boolean, default: false
    field :DENOM, type: Integer
    field :NUMER, type: Integer
    field :DENEX, type: Integer
    field :DENEXCEP, type: Integer
    field :MSRPOPL, type: Integer
    field :OBSERV
    field :antinumerator, type: Integer
    field :IPP, type: Integer
    field :measure_id, type: String
    field :sub_id, type: String
  end
end

