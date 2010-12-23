function () {
  var patient = this;
  var measure = patient.measures["0088"];
  if (measure==null)
    measure={};

  var day = 24*60*60;
  var year = 365*day;
  var effective_date = <%= effective_date %>;
  var latest_birthdate = effective_date - 18*year;
  var earliest_encounter = effective_date - 1*year;
  
  var population = function() {
    encounters = inRange(measure.patient_encounter, earliest_encounter, effective_date);
    retinopathy = inRange(measure.diabetic_retinopathy, earliest_encounter, effective_date);
    return (patient.birthdate<=latest_birthdate) && (encounters>1) && retinopathy;
  }
  
  var denominator = function() {
    return true;
  }
  
  var numerator = function() {
    macular_fundus = inRange(measure.macular_or_fundus_exam, earliest_encounter, effective_date);
    macular_edema = inRange(measure.macular_edema_findings, earliest_encounter, effective_date);
    retinopathy = inRange(measure.level_of_severity_of_retinopathy_findings, earliest_encounter, effective_date);
    retinopathy_and_macular = inRange(measure.severity_of_retinopathy_and_macular_edema_findings, earliest_encounter, effective_date);
    return macular_fundus && ((macular_edema && retinopathy) || retinopathy_and_macular);
  }
  
  var exclusion = function() {
    patient = inRange(measure.patient_reason, earliest_encounter, effective_date);
    medical = inRange(measure.medical_reason, earliest_encounter, effective_date);
    return patient || medical;
  }
  
  map(patient, population, denominator, numerator, exclusion);
};
