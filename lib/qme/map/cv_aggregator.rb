module QME
  module MapReduce

    class CVAggregator

      def self.median(frequencies)
        set_size = frequencies.values.reduce(0, :+)
        offset = set_size.even? ? 1 : 0
        median_positions = [(set_size / 2), (set_size / 2)+offset]

        current_position = 0
        median_left = nil
        median_right = nil

        frequencies.keys.sort.each do |value|
          current_position += frequencies[value]
          
          median_left = value if median_left.nil? && current_position >= median_positions[0] 
          if current_position >= median_positions[1]
            median_right = value 
            break
          end
        end
        median_left ||= 0
        median_right ||= 0
        (median_left + median_right)/2
      end

      def self.mean(frequencies)
        count = frequencies.values.reduce(0, :+)
        sum = frequencies.map {|key,value| key*value}.reduce(0,:+)
        sum/count
      end

    end

  end
end