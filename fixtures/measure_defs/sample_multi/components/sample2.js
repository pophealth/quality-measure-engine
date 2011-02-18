function () {
  var patient = this;
  var measure = patient.measures["test1"];
  if (measure==null)
    measure={};
    
  <%= init_js_frameworks %>

  var year = 365 * 24 * 60 * 60;
  var effective_date =  <%= effective_date %>;
  var earliest_birthdate =  effective_date - 40 * year;
  var latest_birthdate =    effective_date - 5 * year;

  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }
  
  var denominator = function() {
    return patient.gender=='M';
  }

  var numerator = function() {
    return measure.eyes=='blue';
  }

  var exclusion = function() {
    return measure.eyes=='none';
  }

  map(patient, population, denominator, numerator, exclusion);
};