function () {
  var patient = this;
  var measure = patient.measures["0018"];
  if (measure==null)
    measure={};

  var day = 24*60*60;
  var year = 365*day;
  var effective_date = <%= effective_date %>;
  var period_start = effective_date - year;
  var hypertension_diagnosis_end = period_start+year/2;
  var latest_birthdate = effective_date - 18*year;
  var earliest_birthdate = effective_date - 85*year;
  
  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }
  
  var denominator = function() {
    hypertension_diagnosis = inRange(measure.hypertension, period_start, hypertension_diagnosis_end);
    encounter = inRange(measure.encounter_outpatient, period_start, effective_date);
    esrd = inRange(measure.esrd, period_start, effective_date);
    esrd += inRange(measure.procedures_indicative_of_esrd, period_start, effective_date);
    pregnant = inRange(measure.pregnancy, period_start, effective_date);
    return (hypertension_diagnosis && encounter && !(esrd || pregnant));
  }
  
  var numerator = function() {
    latest_encounter = _.max(_.select(measure.encounter_outpatient, function(when){return inRange(when, period_start, effective_date); }));
    // for measure purposes a BP reading is considered to be during an encounter if its timestamp
    // is between 24 hours before and 24 hours after the timestamp of the encounter
    start_latest_encounter = latest_encounter-day;
    end_latest_encounter = latest_encounter+day;
    
    systolic_min = minValueInDateRange(measure.systolic_blood_pressure, start_latest_encounter, end_latest_encounter, 200);
    diastolic_min = minValueInDateRange(measure.diastolic_blood_pressure, start_latest_encounter, end_latest_encounter, 200);
    return (systolic_min<140 && diastolic_min<90);
  }
  
  var exclusion = function() {
    return false;
  }

  map(patient, population, denominator, numerator, exclusion);
};