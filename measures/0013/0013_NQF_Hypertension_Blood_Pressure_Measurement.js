function () {
  var year = 365*24*60*60;
  var effective_date = <%= @effective_date %>;
  var period_start = effective_date - year;
  var latest_birthdate = effective_date - 18*year;
  var measure = this.measures["0013"];
  if (measure==null)
    measure={};
  
  var is_array = function(o) {
    return Object.prototype.toString.call(o) === '[object Array]';
  }
  
  var in_range = function(value, min, max) {
    var count = 0;
    if (is_array(value)) {
      for (i=0;i<value.length;i++) {
        if ((value[i]>=min) && (value[i]<=max))
          count++;
      }
    } else {
      if ((value>=min) && (value<=max))
        count++;
    }
    return count;
  }
  
  var population = function(patient) {
    correct_age = patient.birthdate <= latest_birthdate;
    hypertension = in_range(measure.hypertension, period_start, effective_date);
    encounter_outpatient = in_range(measure.encounter_outpatient, period_start, effective_date);
    encounter_nursing = in_range(measure.encounter_nursing_facility, period_start, effective_date);
    return (correct_age && hypertension && ((encounter_outpatient+encounter_nursing)>=2));
  }
  
  var denominator = function(patient) {
    return true;
  }
  
  var numerator = function(patient) {
    systolic = in_range(measure.systolic_blood_pressure, period_start, effective_date);
    diastolic = in_range(measure.diastolic_blood_pressure, period_start, effective_date);
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