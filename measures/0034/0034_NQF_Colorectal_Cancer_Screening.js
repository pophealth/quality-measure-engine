function () {
  var patient = this;
  var measure = patient.measures["0034"];
  if (measure==null)
    measure={};

  var year = 365*24*60*60;
  var effective_date = <%= effective_date %>;
  var latest_birthdate = effective_date - 50*year;
  var earliest_birthdate = effective_date - 74*year;
  var earliest_encounter = effective_date - 2*year;
  var one_year = effective_date - 1*year;
  var five_years = effective_date - 5*year;
  var ten_years = effective_date - 10*year;
  
  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }
  
  var denominator = function() {
    total_colectomy = measure.total_colectomy!=null && lessThan(measure.total_colectomy, effective_date);
    encounter = inRange(measure.encounter_outpatient, earliest_encounter, effective_date);
    return encounter && !total_colectomy;
  }
  
  var numerator = function() {
    colonoscopy = inRange(measure.colonoscopy, ten_years, effective_date);
    sigmoidoscopy = inRange(measure.flexible_sigmoidoscopy, five_years, effective_date);
    fobt = inRange(measure.fobt, one_year, effective_date);
    return colonoscopy || sigmoidoscopy || fobt;
  }
  
  var exclusion = function() {
    return inRange(measure.colorectal_cancer, one_year, effective_date);
  }
  
  map(patient, population, denominator, numerator, exclusion);
};