function () {
  var patient = this;
  var measure = patient.measures["0056"];
  if (measure==null)
    measure={};

  var year = 365 * 24 * 60 * 60;
  var effective_date =  <%= effective_date %>;
  var earliest_birthdate =  effective_date - 74 * year;
  var latest_birthdate =    effective_date - 17 * year;
  var earliest_diagnosis =  effective_date - 2 * year;

  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }

  var denominator = function() {
    diagnosis_diabetes =            inRange(measure.diagnosis_diabetes, earliest_diagnosis, effective_date);
    encounter_acute_inpatient =     inRange(measure.encounter_acute_inpatient, earliest_diagnosis, effective_date);
    encounter_non_acute_inpatient = inRange(measure.encounter_non_acute_inpatient, earliest_diagnosis, effective_date);
    return (medications_indicative_of_diabetes(measure, earliest_diagnosis, effective_date) 
            || 
            (diagnosis_diabetes && (encounter_acute_inpatient || encounter_non_acute_inpatient == 2)));
  }

  var numerator = function() {
    return inRange(measure.proceedure_foot_exam, earliest_diagnosis, effective_date);
  }

  var exclusion = function() {
    diagnosis_gestational_diabetes =        inRange(measure.diagnosis_gestational_diabetes, earliest_diagnosis, effective_date);
    diagnosis_steroid_induced_diabetes =    inRange(measure.diagnosis_steroid_induced_diabetes, earliest_diagnosis, effective_date);
    return ((measure.polycystic_ovaries && !(diagnosis_diabetes && (encounter_acute_inpatient || encounter_non_acute_inpatient)))
            ||
            ((diagnosis_gestational_diabetes || diagnosis_steroid_induced_diabetes) 
             && medications_indicative_of_diabetes(measure, earliest_diagnosis, effective_date) 
             && !(diagnosis_diabetes && (encounter_acute_inpatient || encounter_non_acute_inpatient))));
  }

  map(patient, population, denominator, numerator, exclusion);

};