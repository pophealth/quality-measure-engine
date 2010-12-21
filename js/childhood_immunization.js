// Adds childhood immunization utility functions to the root JS object. These 
// are then available for use by the supporting map-reduce functions for any 
// measure that needs common definitions of childhood-immunization-specific 
// algorithms.
//
// lib/qme/mongo_helpers.rb executes this function on a database
// connection.
(function() {

  var root = this;

  root.has_outpatient_encounter_with_pcp_obgyn = function(measure, earliest_diagnosis, effective_date) {
    return inRange(measure.outpatient_with_pcp_and_obgyn_encounter, earliest_diagnosis, effective_date);
  }

})();