function () {
  var year = 365*24*60*60;
  var effective_date = <%= @effective_date %>;
  var earliest_birthdate = effective_date - 64*year;
  var latest_birthdate = effective_date - 23*year;
  var earliest_encounter = effective_date - 2*year;
  var earliest_pap = effective_date - 3*year;
  var measure = this.measures["0032"];
  
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
    } else if ((value>=min) && (value<=max)) {
      count++;
    }
    return count;
  }
  
  var population = function(patient) {
    return in_range(patient.birthdate, earliest_birthdate, latest_birthdate);
  }
  
  var denominator = function(patient) {
    outpatient_encounter = in_range(measure.encounter_outpatient, earliest_encounter, effective_date);
    obgyn_encounter = in_range(measure.encounter_obgyn, earliest_encounter, effective_date);
    no_hysterectomy = (measure.hysterectomy==null || measure.hysterectomy>=effective_date);
    return ((outpatient_encounter || obgyn_encounter) && no_hysterectomy);
  }
  
  var numerator = function(patient) {
    return in_range(measure.pap_test, earliest_pap, effective_date);
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