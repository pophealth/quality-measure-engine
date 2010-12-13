// Adds common utility functions to the root JS object. These are then
// available for use by the map-reduce functions for each measure.
// lib/qme/mongo_helpers.rb executes this function on a database
// connection.
(function() {

  var root = this;

  root.medications_indicative_of_diabetes = function(measure, earliest_diagnosis, effective_date) {
    return (   inRange(measure.medication_alpha_glucosidas_inhibitors, earliest_diagnosis, effective_date)
            || inRange(measure.medication_amylin_analogs,              earliest_diagnosis, effective_date)
            || inRange(measure.medication_antidiabetic_agent,          earliest_diagnosis, effective_date)
            || inRange(measure.medication_antidiabetic_combinations,   earliest_diagnosis, effective_date)
            || inRange(measure.medication_biguanides,                  earliest_diagnosis, effective_date)
            || inRange(measure.medication_insulin,                     earliest_diagnosis, effective_date)
            || inRange(measure.medication_meglitinides,                earliest_diagnosis, effective_date)
            || inRange(measure.medication_sulfonylureas,               earliest_diagnosis, effective_date)
            || inRange(measure.medication_thiazolidinediones,          earliest_diagnosis, effective_date));
  };

})();