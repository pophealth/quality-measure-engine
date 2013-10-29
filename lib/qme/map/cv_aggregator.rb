module QME
  module MapReduce

    class CVAggregator

      def self.median(frequencies)
        set_size = frequencies.values.reduce(0, :+)
        offset = set_size.even? ? 1 : 0
        left_position, right_position = [(set_size / 2), (set_size / 2) + offset]
        current_position = -1 + offset #compensate for integer math flooring

        median_left = nil
        median_right = nil

        frequencies.keys.sort.each do |value|
          current_position += (frequencies[value])

          if current_position >= left_position && median_left == nil
            median_left = value
            return median_left if set_size.odd?
          end

          if current_position >= right_position
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
        result = 0
        result = sum/count if count > 0
        result
      end

    end

  end
end
