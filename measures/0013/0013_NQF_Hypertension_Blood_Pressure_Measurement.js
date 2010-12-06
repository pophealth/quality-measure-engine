function () {
  var year = 365*24*60*60;
  var effective_date = <%= @effective_date %>;
  var period_start = effective_date - year;
  var latest_birthdate = effective_date - 18*year;
  var measure = this.measures["0013"];
  if (measure==null)
    measure={};
  
  var population = function(patient) {
    correct_age = patient.birthdate <= latest_birthdate;
    hypertension = inRange(measure.hypertension, period_start, effective_date);
    encounter_outpatient = inRange(measure.encounter_outpatient, period_start, effective_date);
    encounter_nursing = inRange(measure.encounter_nursing_facility, period_start, effective_date);
    return (correct_age && hypertension && ((encounter_outpatient+encounter_nursing)>=2));
  }
  
  var denominator = function(patient) {
    return true;
  }
  
  var numerator = function(patient) {
    systolic = inRange(measure.systolic_blood_pressure, period_start, effective_date);
    diastolic = inRange(measure.diastolic_blood_pressure, period_start, effective_date);
    return (systolic && diastolic);
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