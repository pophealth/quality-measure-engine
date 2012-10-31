module QME
  class QualityMeasure
    include DatabaseAccess
    extend DatabaseAccess
    determine_connection_information
    
    # Return a list of the measures in the database
    # @return [Hash] an hash of measure definitions
    def self.all
      result = {}
      measures = get_db()['measures']
      measures.find().each do |measure|
        id = measure['id']
        sub_id = measure['sub_id']
        measure_id = "#{id}#{sub_id}.json"
        result[measure_id] ||= measure
      end
      result
    end
    
    def self.get_measures(measure_ids)
      get_db()['measures'].find('id' => {"$in" => measure_ids})
    end
    
    # Creates a new QualityMeasure
    # @param [String] measure_id value of the measure's id field
    # @param [String] sub_id value of the measure's sub_id field, may be nil for measures with only a single numerator and denominator
    def initialize(measure_id, sub_id = nil)
      @measure_id = measure_id
      @sub_id = sub_id
      determine_connection_information
    end
    
    # Retrieve a measure definition from the database
    # @return [Hash] a JSON hash of the encoded measure
    def definition
      measures = get_db()['measures']
      if @sub_id
        measures.find({'id' => @measure_id, 'sub_id' => @sub_id}).first()
      else
        measures.find({'id' => @measure_id}).first()
      end
    end
  end
end