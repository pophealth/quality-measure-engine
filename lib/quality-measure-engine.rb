Bundler.require(:default)

LIB = File.dirname(__FILE__)

require LIB + '/qme/map/map_reduce_builder'
require LIB + '/qme/map/map_reduce_executor'

require 'singleton'

require LIB + '/qme/importer/patient_importer'
require LIB + '/qme/importer/code_system_helper'
require LIB + '/qme/importer/hl7_helper'
require LIB + '/qme/importer/measure_base'

require LIB + '/qme/mongo_helpers'

# Require all of the ruby files in the measure directory
Dir.glob(File.join(LIB, 'qme', 'importer', 'measure', '*.rb')).each do |measure_rb|
  require measure_rb.sub('.rb', '')
end

require 'json'
require 'mongo'

pi = QME::Importer::PatientImporter.instance

# TODO: *rjm We need to use the database when we pull the JSON definitions for all of the
# quality measures, instead of using the file system.
raw_measure_json = File.read(LIB + '/../measures/0032/0032_NQF_Cervical_Cancer_Screening.json')
measure_json = JSON.parse(raw_measure_json)
ccs = QME::Importer::Measure::CervicalCancerScreening.new(measure_json)
pi.add_measure(ccs)

raw_measure_json = File.read(LIB + '/../measures/0043/0043_NQF_Pneumonia_Vaccination_Status_For_Older_Adults.json')
measure_json = JSON.parse(raw_measure_json)
pvs = QME::Importer::Measure::PneumoniaVaccinationStatus.new(measure_json)
pi.add_measure(pvs)

raw_measure_json = File.read(LIB + '/../measures/0013/0013_NQF_Hypertension_Blood_Pressure_Measurement.json')
measure_json = JSON.parse(raw_measure_json)
pvs = QME::Importer::Measure::Hypertension.new(measure_json)
pi.add_measure(pvs)

raw_measure_json = File.read(LIB + '/../measures/0028/components/root.json')
measure_json = JSON.parse(raw_measure_json)
pvs = QME::Importer::Measure::TobaccoUseScreening.new(measure_json)
pi.add_measure(pvs)

# TODO: *rjm  This importer only uses about 90% of the data because the numerator 
# for all of the diabetes measures is defined in the 'diabetes.col' file.  To really 
# validate that the diabetes importers are working, the JSON should be extracted
# from the database, and not the file system
raw_measure_json = File.read(LIB + '/../measures/diabetes/components/root.json')
measure_json = JSON.parse(raw_measure_json)
dee = QME::Importer::Measure::DiabetesEyeExam.new(measure_json)
pi.add_measure(dee)