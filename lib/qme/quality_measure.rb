module QME
  class QualityMeasure
    include DatabaseAccess
    extend DatabaseAccess
    determine_connection_information
    
    # Return a list of the measures in the database
    # @return [Hash] an hash of measure definitions
    def self.all(bundle_id = nil)
      result = {}
      measures = query_measures({}, bundle_id)
      measures.find_all.each do |measure|
        id = measure['id']
        sub_id = measure['sub_id']
        measure_id = "#{id}#{sub_id}.json"
        result[measure_id] ||= measure
      end
      result
    end
    
    def self.get_measures(measure_ids, bundle_id = nil)
      query_measures({'id' => {"$in" => measure_ids}}, bundle_id)
    end

    def self.get(measure_id, sub_id, bundle_id = nil)
      query_measures({'id' => measure_id, 'sub_id' => sub_id}, bundle_id)
    end

    def self.sub_measures(measure_id, bundle_id = nil)
      query_measures({'id' => measure_id}, bundle_id)
    end
    
    # Creates a new QualityMeasure
    # @param [String] measure_id value of the measure's id field
    # @param [String] sub_id value of the measure's sub_id field, may be nil for measures with only a single numerator and denominator
    def initialize(measure_id, sub_id = nil, bundle_id = nil)
      @measure_id = measure_id
      @sub_id = sub_id
      @bundle_id = bundle_id
      determine_connection_information
    end
    
    # Retrieve a measure definition from the database
    # @return [Hash] a JSON hash of the encoded measure
    def definition
      if @sub_id
        QME::QualityMeasure.query_measures({'id' => @measure_id, 'sub_id' => @sub_id}, @bundle_id).first()
      else
        QME::QualityMeasure.query_measures({'id' => @measure_id}, @bundle_id).first()
      end
    end

    # Build measure collection query. Allows scoping of query to a single bundle
    # @param [String] criteria Moped query hash
    # @param [String] bundle_id the MongoDB id of the bundle to scope the query against. Leaving this as nil will scope to all bundles
    def self.query_measures(criteria, bundle_id=nil)
      criteria = bundle_id ? criteria.merge!({'bundle_id' => bundle_id}): criteria
      get_db()['measures'].find(criteria)
    end
  end
end