function () {
  var patient = this;
  var measure = patient.measures["0014"];
  if (measure==null)
    measure={};

  var day = 24*60*60;
  var year = 365 * day;
  var effective_date =  <%= effective_date %>;
  var earliest_encounter = effective_date - year;

  var population = function() {
    live_birth_diagnosis = inRange(measure.delivery_live_births_diagnosis, earliest_encounter, effective_date);
    live_birth_procedure = inRange(measure.delivery_live_births_procedure, earliest_encounter, effective_date);
    return live_birth_diagnosis && live_birth_procedure;
  }
  
  var denominator = function() {
    if (!measure.estimated_date_of_conception)
      return false;
    estimated_conception = _.max(measure.estimated_date_of_conception);
    prenatal_encounter = inRange(measure.prenatal_visit, estimated_conception, effective_date);
    drh_neg_diagnosis = inRange(measure.drh_negative, earliest_encounter, effective_date);
    primigravida = inRange(measure.primigravida, earliest_encounter, effective_date);
    multigravida = inRange(measure.multigravida, earliest_encounter, effective_date);
    rh_status_mother = minValueInDateRange(measure.rh_status_mother, earliest_encounter, effective_date, false)
    rh_status_baby = minValueInDateRange(measure.rh_status_mother, earliest_encounter, effective_date, false)
    return prenatal_encounter && drh_neg_diagnosis && (
      (primigravida && !rh_status_mother) || 
      (multigravida && !rh_status_mother && !rh_status_baby));
  }

  var numerator = function() {
    estimated_conception = _.max(measure.estimated_date_of_conception);
    estimated_conception_within_ten_months = actionFollowingSomething(estimated_conception, measure.delivery_live_births_procedure, 304*day);
    
    antid_admin_within_30_weeks = actionFollowingSomething(estimated_conception, measure.anti_d_immune_globulin, 30*7*day);
    antid_admin_within_26_weeks = actionFollowingSomething(estimated_conception, measure.anti_d_immune_globulin, 26*7*day);
    
    return estimated_conception_within_ten_months && antid_admin_within_30_weeks && !antid_admin_within_26_weeks;
  }

  var exclusion = function() {
    medical_reason = inRange(measure.medical_reason, earliest_encounter, effective_date);
    patient_reason = inRange(measure.patient_reason, earliest_encounter, effective_date);
    system_reason = inRange(measure.system_reason, earliest_encounter, effective_date);
    return system_reason || medical_reason || patient_reason;
  }

  map(patient, population, denominator, numerator, exclusion);
};