function () {
  var patient = this;
  var measure = patient.measures["0032"];
  if (measure==null)
    measure={};

  var year = 365*24*60*60;
  var effective_date = <%= @effective_date %>;
  var earliest_birthdate = effective_date - 64*year;
  var latest_birthdate = effective_date - 23*year;
  var earliest_encounter = effective_date - 2*year;
  var earliest_pap = effective_date - 3*year;
  
  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }
  
  var denominator = function() {
    outpatient_encounter = inRange(measure.encounter_outpatient, earliest_encounter, effective_date);
    obgyn_encounter = inRange(measure.encounter_obgyn, earliest_encounter, effective_date);
    no_hysterectomy = (measure.hysterectomy==null || measure.hysterectomy>=effective_date);
    return ((outpatient_encounter || obgyn_encounter) && no_hysterectomy);
  }
  
  var numerator = function() {
    return inRange(measure.pap_test, earliest_pap, effective_date);
  }
  
  var exclusion = function() {
    return false;
  }
  
  result = map(population, denominator, numerator, exclusion);
  emit(null, result);
};