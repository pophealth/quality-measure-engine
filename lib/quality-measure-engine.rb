Bundler.require(:default)

LIB = File.dirname(__FILE__)

require LIB + '/qme/map/map_reduce_builder'
require LIB + '/qme/map/map_reduce_executor'

require 'singleton'

require LIB + '/qme/importer/patient_importer'
require LIB + '/qme/importer/code_system_helper'
require LIB + '/qme/importer/hl7_helper'
require LIB + '/qme/importer/measure_base'

# Require all of the ruby files in the measure directory
Dir.glob(File.join(LIB, 'qme', 'importer', 'measure', '*.rb')).each do |measure_rb|
  require measure_rb.sub('.rb', '')
end

require 'json'
require 'mongo'

pi = QME::Importer::PatientImporter.instance

raw_measure_json = File.read(LIB + '/../measures/0032/0032_NQF_Cervical_Cancer_Screening.json')
measure_json = JSON.parse(raw_measure_json)
ccs = QME::Importer::Measure::CervicalCancerScreening.new(measure_json)
pi.add_measure(ccs)

raw_measure_json = File.read(LIB + '/../measures/0043/0043_NQF_Pneumonia_Vaccination_Status_For_Older_Adults.json')
measure_json = JSON.parse(raw_measure_json)
pvs = QME::Importer::Measure::PneumoniaVaccinationStatus.new(measure_json)
pi.add_measure(pvs)
