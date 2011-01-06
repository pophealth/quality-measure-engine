function () {
  var patient = this;
  var measure = patient.measures["0385"];
  if (measure==null)
    measure={};

  var year = 365*24*60*60;
  var effective_date = <%= effective_date %>;
  var latest_birthdate = effective_date - 18*year;
  var earliest_encounter = effective_date - 1*year;
  var latest_encounter = maxInRange(measure.encounter_office_visit, earliest_encounter, effective_date);
  
  var population = function() {
    age_match = patient.birthdate <= latest_birthdate;
    if (!latest_encounter)
      return false;
    colon_cancer = lessThan(measure.colon_cancer, latest_encounter); 
    colon_cancer_history = lessThan(measure.colon_cancer_history, latest_encounter);
    encounter_count = inRange(measure.encounter_office_visit, earliest_encounter, effective_date);
    return age_match && (colon_cancer || colon_cancer_history) && (encounter_count>1);
  }
  
  var denominator = function() {
    colon_cancer_iii = lessThan(measure.colon_cancer_stage_iii, latest_encounter); 
    return colon_cancer_iii;
  }
  
  var numerator = function() {
    chemo = lessThan(measure.chemotherapy_for_colon_cancer, latest_encounter);
    return chemo;
  }
  
  var exclusion = function() {
    metastatic_sites = lessThan(measure.metastatic_sites_common_to_colon_cancer, latest_encounter);
    renal_isufficiency = lessThan(measure.acute_renal_insufficiency, latest_encounter);
    neutropenia = lessThan(measure.neutropenia, latest_encounter);
    leukopenia = lessThan(measure.leukopenia, latest_encounter);
    ecog = lessThan(measure.ecog_performance_status_poor, latest_encounter);
    allergy = lessThan(measure.allergy_chemotherapy_for_colon_cancer, latest_encounter);
    medical = inRange(measure.medical_reason, earliest_encounter, effective_date);
    patient = inRange(measure.patient_reason, earliest_encounter, effective_date);
    system = inRange(measure.system_reason, earliest_encounter, effective_date);
    return metastatic_sites || renal_isufficiency || neutropenia || leukopenia || ecog || allergy
      || medical || patient || system;
  }
  
  map(patient, population, denominator, numerator, exclusion);
};