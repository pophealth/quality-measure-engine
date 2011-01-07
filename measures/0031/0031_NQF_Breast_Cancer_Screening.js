function () {
  var patient = this;
  var measure = patient.measures["0031"];
  if (measure==null)
    measure={};

  var year = 365*24*60*60;
  var effective_date = <%= effective_date %>;
  var earliest_birthdate = effective_date - 68*year;
  var latest_birthdate = effective_date - 41*year;
  var earliest_encounter = effective_date - 2*year;

  var population = function() {
    return patient.gender == "F" && inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }
  
  var denominator = function() {
    var outpatient_encounter = inRange(measure.encounter_outpatient, earliest_encounter, effective_date);
    // look for bilateral mastectomy or unilateral mastectomy
   var has_breast = (!measure.bilateral_mastectomy && _.uniq(measure.unilateral_mastectomy || []).length <=1  );
    return (outpatient_encounter && has_breast);
  }
  
  var numerator = function() {
    return inRange(measure.breast_cancer_screening, earliest_encounter, effective_date);
  }
  
  var exclusion = function() {
    return false;
  }
  
  map(patient, population, denominator, numerator, exclusion);
};