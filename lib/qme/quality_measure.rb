module QME
  class QualityMeasure

    include Mongoid::Document
    store_in collection: 'measures'

    field :id, as: :id, type: String
    field :sub_id, type: String
    field :map_fn, type: String
    field :nqf_id, type: String
    field :continuous_variable, type: Boolean, default: false
    field :aggregator, type: String
    field :map_fn, type: String
    field :population_ids, type: Hash
    field :parameters, type: Hash, default: {}

  end
end