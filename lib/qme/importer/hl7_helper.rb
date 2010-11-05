module QME
  module Importer
    
    # General helpers for working with HL7 data types
    class HL7Helper
      
      # Converts an HL7 timestamp into an Integer
      # @param [String] timestamp the HL7 timestamp. Expects YYYYMMDD format
      # @return [Integer] Date in seconds since the epoch
      def self.timestamp_to_integer(timestamp)
        Time.gm(timestamp[0..3].to_i,
                timestamp[4..5].to_i,
                timestamp[6..7].to_i).to_i
      end
    end
  end
end