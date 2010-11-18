function () {
  var year = 365*24*60*60;
  var effective_date = <%= @effective_date %>;
  var earliest_birthdate = effective_date - 65*year;
  var earliest_encounter = effective_date - 1*year;
  var measure = this.measures["0043"];
  
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
    return (patient.birthdate <= earliest_birthdate);
  }
  
  var denominator = function(patient) {
    outpatient_encounter = in_range(measure.encounter, earliest_encounter, effective_date);
    return (outpatient_encounter);
  }
  
  var numerator = function(patient) {
    return (measure.vaccination <= effective_date);
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