function () {
  var patient = this;
  var measure = patient.measures["0043"];
  if (measure==null)
    measure={};

  var year = 365*24*60*60;
  var effective_date = <%= @effective_date %>;
  var earliest_birthdate = effective_date - 65*year;
  var earliest_encounter = effective_date - 1*year;
  
  var population = function() {
    return (patient.birthdate <= earliest_birthdate);
  }
  
  var denominator = function() {
    outpatient_encounter = inRange(measure.encounter, earliest_encounter, effective_date);
    return (outpatient_encounter);
  }
  
  var numerator = function() {
    return (measure.vaccination <= effective_date);
  }
  
  var exclusion = function() {
    return false;
  }
  
  map(population, denominator, numerator, exclusion);
};