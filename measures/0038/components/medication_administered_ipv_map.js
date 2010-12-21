function () {
  var patient = this;
  var measure = patient.measures["0038"];
  if (measure==null)
    measure={};

  var year = 365 * 24 * 60 * 60;
  var effective_date =      <%= effective_date %>;
  var earliest_birthdate =      effective_date - 2 * year;
  var latest_birthdate =        effective_date - 1 * year;

  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }

  var denominator = function() {
    return false;
  }

  var numerator = function() {
    return has_outpatient_encounter_with_pcp_obgyn(measure, earliest_diagnosis, effective_date);
  }

  var exclusion = function() {
    return false;
  }

  map(patient, population, denominator, numerator, exclusion);
};