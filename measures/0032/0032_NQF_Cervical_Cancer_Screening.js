function () {
  var year = 365*24*60*60;
  var effective_date = <%= @effective_date %>;
  var earliest_birthdate = effective_date - 64*year;
  var latest_birthdate = effective_date - 23*year;
  var earliest_encounter = effective_date - 2*year;
  var earliest_pap = effective_date - 3*year;
  var measure = this.measures["0032"];
  if (measure==null)
    measure={};
  
  var population = function(patient) {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }
  
  var denominator = function(patient) {
    outpatient_encounter = inRange(measure.encounter_outpatient, earliest_encounter, effective_date);
    obgyn_encounter = inRange(measure.encounter_obgyn, earliest_encounter, effective_date);
    no_hysterectomy = (measure.hysterectomy==null || measure.hysterectomy>=effective_date);
    return ((outpatient_encounter || obgyn_encounter) && no_hysterectomy);
  }
  
  var numerator = function(patient) {
    return inRange(measure.pap_test, earliest_pap, effective_date);
  }
  
  var exclusion = function(patient) {
    return false;
  }
  
  var value = {i: 0, d: 0, n: 0, e: 0};
  if (population(this)) {
    value.i++;
    if (denominator(this)) {
      value.d++;
      if (numerator(this)) {
        value.n++;
      } else if (exclusion(this)) {
        value.e++;
        value.d--;
      }
    }
  }
  emit(null, value);
};