// Adds weight management utility functions to the root JS object. These are then
// available for use by the supporting map-reduce functions for any measure
// that needs common definitions of diabetes-specific algorithms.
// lib/qme/mongo_helpers.rb executes this function on a database
// connection.
(function() {

  var root = this;

  root.weight_denominator = function(measure, period_start, effective_date) {
    encounter = inRange(measure.patient_encounter, period_start, effective_date);
    pregnant = inRange(measure.encounter_pregnancy, period_start, effective_date);
    pregnancy_encounter = inRange(measure.encounter_pregnancy, period_start, effective_date);
    return encounter && !(pregnant || pregnancy_encounter);
  }
  
  root.weight_population = function(patient, earliest_birthdate, latest_birthdate) {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }  

})();