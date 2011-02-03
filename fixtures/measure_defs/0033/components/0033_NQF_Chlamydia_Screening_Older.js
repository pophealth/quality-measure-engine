function () {
  var patient = this;
  var measure = patient.measures["0033"];
  if (measure==null)
    measure={};

  <%= init_js_frameworks %>

  
  var day = 24*60*60;
  var year = 365*day;
  var effective_date = <%= effective_date %>;
  var earliest_birthdate = effective_date - 23*year;
  var latest_birthdate = effective_date - 20*year;
  var earliest_encounter = effective_date - 1*year;
  
  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }
  
  var denominator = function() {
    outpatient_encounter = inRange(measure.encounter_outpatient, earliest_encounter, effective_date);
    indicative_procedure = inRange(measure.procedures_indicative_of_sexually_active_woman, earliest_encounter, effective_date);
    pregnancy_test = inRange(measure.pregnancy_test, earliest_encounter, effective_date);
    iud = inRange(measure.iud_use, earliest_encounter, effective_date);
    education = inRange(measure.contraceptive_use_education, earliest_encounter, effective_date);
    contraceptives = inRange(measure.contraceptives, earliest_encounter, effective_date);
    pregnancy_encounter = inRange(measure.encounter_pregnancy, earliest_encounter, effective_date);
    indicative_labs = inRange(measure.laboratory_tests_indicative_of_sexually_active_women, earliest_encounter, effective_date);
    active = inRange(measure.sexually_active_woman, earliest_encounter, effective_date);
    
    return outpatient_encounter && (indicative_procedure || pregnancy_test || iud || education || contraceptives || pregnancy_encounter || indicative_labs || active);
  }
  
  var numerator = function() {
    return inRange(measure.chlamydia_screening, earliest_encounter, effective_date);
  }
  
  var exclusion = function() {
    pregnancy_test = inRange(measure.pregnancy_test, earliest_encounter, effective_date);
    if (!pregnancy_test)
      return false;
    
    var inMeasureDateRange = function(reading) {
      result = inRange(reading, earliest_encounter, effective_date);
      return result;
    };
    
    if (!_.isArray(measure.pregnancy_test))
      measure.pregnancy_test = [measure.pregnancy_test];
    pregnancyTestsInMeasureRange = _.select(measure.pregnancy_test, inMeasureDateRange);
    
    retinoid = actionFollowingSomething(pregnancyTestsInMeasureRange, measure.retinoid, 7*day);
    x_ray = actionFollowingSomething(pregnancyTestsInMeasureRange, measure.x_ray_study, 7*day);
    return retinoid || x_ray;
  }
  
  map(patient, population, denominator, numerator, exclusion);
};