function () {
  var patient = this;
  var measure = patient.measures["0027"];
  if (measure==null)
    measure={};

  var year = 365*24*60*60;
  var effective_date = <%= effective_date %>;
  var latest_birthdate = effective_date - 18*year;
  var earliest_encounter = effective_date - 2*year;
  var earliest_tobacco_user = effective_date - 1*year;
  
  var population = function() {
    return (patient.birthdate<=latest_birthdate);
  }
  
  var denominator = function() {
    return inRange(measure.encounter_outpatient, earliest_encounter, effective_date);
  }
  
  var numerator = function() {
    return inRange(measure.tobacco_user, earliest_tobacco_user, effective_date);
  }
  
  var exclusion = function() {
    return false;
  }
  
  map(patient, population, denominator, numerator, exclusion);
};