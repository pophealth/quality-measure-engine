function () {
  var patient = this;
  var measure = patient.measures["0024"];
  if (measure==null)
    measure={};

  var day = 24*60*60;
  var year = 365*day;
  var effective_date = <%= effective_date %>;
  var period_start = effective_date - year;
  var latest_birthdate = effective_date - 2*year;
  var earliest_birthdate = effective_date - 10*year;
  
  var population = function() {
    return weight_population(patient, earliest_birthdate, latest_birthdate);
  }
  
  var denominator = function() {
    return weight_denominator(measure, period_start, effective_date);
  }
  
  var numerator = function() {
    return inRange(measure.counseling_for_nutrition, period_start, effective_date);
  }
  
  var exclusion = function() {
    return false;
  }

  map(patient, population, denominator, numerator, exclusion);
};