function () {
  var patient = this;
  var measure = patient.measures["0056"];
  if (measure==null)
    measure={};

  // TODO: rjm Get these definitions into the 'diabetes_utils.js' file
  // that is located in the /js directory of the project for shared 
  // code across all of the diabetes measures. 
  var year = 365 * 24 * 60 * 60;
  var effective_date =  <%= effective_date %>;
  var earliest_birthdate =  effective_date - 74 * year;
  var latest_birthdate =    effective_date - 17 * year;
  var earliest_diagnosis =  effective_date - 2 * year;

  var population = function() {
    return diabetes_population(patient, earliest_birthdate, latest_birthdate);
  }

  var denominator = function() {
    return diabetes_denominator(measure, earliest_diagnosis, effective_date);
  }

  // This numerator function is the only code that is specific to this particular 
  // MU diabetes measure.  All of the other definitions for the initial population, 
  // the denominator, and the exclusions are shared in the 'diabetes_utils.js' file
  // that is located in the /js directory of the project
  var numerator = function() {
    return inRange(measure.procedure_foot_exam, earliest_diagnosis, effective_date);
  }

  var exclusion = function() {
    return diabetes_exclusions(measure, earliest_diagnosis, effective_date);
  }

  map(patient, population, denominator, numerator, exclusion);
};