function () {
  var patient = this;
  var measure = patient.measures["0062"];
  if (measure==null)
    measure={};

  var day = 24 * 60 * 60;
  var year = 365 * day;
  var effective_date =                <%= effective_date %>;
  var period_start =                      effective_date - year;
  var earliest_birthdate =                effective_date - 74 * year;
  var latest_birthdate =                  effective_date - 17 * year;
  var earliest_diagnosis =                effective_date - 2 * year;
  var year_prior_to_measurement_period =  effective_date - 3 * year;

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
    nephropathy = inRange(measure.nephropathy_diagnosis, period_start, effective_date);
    nephropathy_proc = inRange(measure.nephropathy_related_procedure, period_start, effective_date);
    urine_microalbumin = inRange(measure.urine_microalbumin, period_start, effective_date);
    nephropathy_screen = inRange(measure.nephropathy_screening, period_start, effective_date);
    ace_arb = inRange(measure.ace_inhibitors_or_arbs, period_start, effective_date);
    return (nephropathy || nephropathy_proc || urine_microalbumin || nephropathy_screen || ace_arb);
  }

  var exclusion = function() {
    return diabetes_exclusions(measure, earliest_diagnosis, effective_date);
  }

  map(patient, population, denominator, numerator, exclusion);
};