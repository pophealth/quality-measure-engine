module QME
  module MapReduce
    # Injects the effective start date into the map reduce function of a measure
    # if provided
    class EffectiveStartDateInjector
      def initialize(map_fn:, effective_start_date:)
        @map_fn = map_fn
        @effective_start_date = effective_start_date
      end

      def execute
        return map_fn unless effective_start_date

        self.map_fn = map_fn.gsub(
          /(<%= effective_date %>;)/,
          '\1 var effective_start_date = <%= effective_start_date %>;'
        )
        self.map_fn = map_fn.gsub(
          "MeasurePeriod.low.date = new Date(1000*(effective_date+60));\n  MeasurePeriod.low.date.setFullYear(MeasurePeriod.low.date.getFullYear()-1);",
          'MeasurePeriod.low.date = new Date(1000*effective_start_date);'
        )
        map_fn
      end

      private

      attr_reader :effective_start_date
      attr_accessor :map_fn
    end
  end
end
