function () {
  var year = 365*24*60*60;
  var effective_date = <%= @effective_date %>;
  var earliest_birthdate = effective_date - 65*year;
  var earliest_encounter = effective_date - 1*year;
  var measure = this.measures["0043"];
  if (measure==null)
    measure={};
  
  var population = function(patient) {
    return (patient.birthdate <= earliest_birthdate);
  }
  
  var denominator = function(patient) {
    outpatient_encounter = inRange(measure.encounter, earliest_encounter, effective_date);
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