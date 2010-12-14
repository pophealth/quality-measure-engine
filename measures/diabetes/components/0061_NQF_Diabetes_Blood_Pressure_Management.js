function () {
  var patient = this;
  var measure = patient.measures["0061"];
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
    var latest_encounter_acute_inpatient=null, latest_encounter_non_acute_inpatient=null, latest_encounter_outpatient=null, latest_encounter_outpatient_opthamological_services=null;
    if (measure.encounter_acute_inpatient)
      latest_encounter_acute_inpatient = _.max(_.select(measure.encounter_acute_inpatient, function(when){return inRange(when, period_start, effective_date); }));
    if (measure.encounter_non_acute_inpatient)
      latest_encounter_non_acute_inpatient = _.max(_.select(measure.encounter_non_acute_inpatient, function(when){return inRange(when, period_start, effective_date); }));
    if (measure.encounter_outpatient)
      latest_encounter_outpatient = _.max(_.select(measure.encounter_outpatient, function(when){return inRange(when, period_start, effective_date); }));
    if (measure.encounter_outpatient_opthamological_services)
      latest_encounter_outpatient_opthamological_services = _.max(_.select(measure.encounter_outpatient_opthamological_services, function(when){return inRange(when, period_start, effective_date); }));
    latest_encounter = _.max([latest_encounter_acute_inpatient, latest_encounter_non_acute_inpatient, latest_encounter_outpatient, latest_encounter_outpatient_opthamological_services]);

    if (latest_encounter==null)
      return false;
      
    // for measure purposes a BP reading is considered to be during an encounter if its timestamp
    // is between 24 hours before and 24 hours after the timestamp of the encounter
    start_latest_encounter = latest_encounter-day;
    end_latest_encounter = latest_encounter+day;
    
    systolic_min = minValueInDateRange(measure.systolic_blood_pressure, start_latest_encounter, end_latest_encounter, 200);
    diastolic_min = minValueInDateRange(measure.diastolic_blood_pressure, start_latest_encounter, end_latest_encounter, 200);
    return (systolic_min<140 && diastolic_min<90);
  }
  
  var exclusion = function() {
    return diabetes_exclusions(measure, earliest_diagnosis, effective_date);
  }

  map(patient, population, denominator, numerator, exclusion);
};