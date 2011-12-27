module QME
  module Randomizer
    class RandomPatientCreator
      
      # Parses a patient hash containing demographic and event information
      #
      # @param [Hash] patient_hash patient data
      # @return [Record] a representation of the patient that can be inserted into MongoDB
      def self.parse_hash(patient_hash)
        patient_record = Record.new
        patient_record.first = patient_hash['first']
        patient_record.last = patient_hash['last']
        patient_record.gender = patient_hash['gender']
        patient_record.medical_record_number = patient_hash['patient_id']
        patient_record.birthdate = patient_hash['birthdate']
        patient_record.race = patient_hash['race']
        patient_record.ethnicity = patient_hash['ethnicity']
        #patient_record['languages'] = patient_hash['languages']
        #patient_record['addresses'] = patient_hash['addresses']
        patient_hash['events'].each do |key, value|
          patient_record.send("#{key}=".to_sym, parse_events(value))
        end
        patient_record['measures'] = QME::Importer::MeasurePropertiesGenerator.instance.generate_properties(patient_record)
        
        patient_record
      end
      
      # Parses a list of event hashes into an array of Entry objects
      #
      # @param [Array] event_list list of event hashes
      # @return [Array] array of Entry objects
      def self.parse_events(event_list)
        event_list.collect do |event|
          if event.class==String.class
            # skip String elements in the event list, patient randomization templates
            # introduce String elements to simplify tailing-comma handling when generating
            # JSON using ERb
            nil
          else
            Entry.from_event_hash(event)
          end
        end.compact
      end
    end
  end
end