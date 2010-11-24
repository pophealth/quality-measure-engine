function () {
  var day = 24*60*60;
  var year = 365*day;
  var effective_date = <%= @effective_date %>;
  var earliest_birthdate = effective_date - 50*year;
  var earliest_encounter = effective_date - 1*year;
  var start_flu_encounter = effective_date - 122*day;
  var end_flu_encounter = effective_date - 58*day;
  var measure = this.measures["0041"];
  
  var is_array = function(o) {
    return Object.prototype.toString.call(o) === '[object Array]';
  }
  
  var in_range = function(value, min, max) {
    var count = 0;
    if (is_array(value)) {
      for (i=0;i<value.length;i++) {
        if ((value[i]>=min) && (value[i]<=max))
          count++;
      }
    } else if ((value>=min) && (value<=max)) {
      count++;
    }
    return count;
  }
  
  var population = function(patient) {
    outpatient_encounters = in_range(measure.encounter_outpatient, earliest_encounter, effective_date);
    other_encounters = 
      in_range(measure.encounter_prev_med_40_or_older, earliest_encounter, effective_date) +
      in_range(measure.encounter_prev_med_group, earliest_encounter, effective_date) +
      in_range(measure.encounter_prev_med_ind, earliest_encounter, effective_date) +
      in_range(measure.encounter_prev_med_other, earliest_encounter, effective_date) +
      in_range(measure.encounter_nursing, earliest_encounter, effective_date) +
      in_range(measure.encounter_nursing_discharge, earliest_encounter, effective_date);
    return (patient.birthdate<=earliest_birthdate && (outpatient_encounters>1 || other_encounters>0));
  }
  
  var denominator = function(patient) {
    flu_encounters = 
      in_range(measure.encounter_outpatient, start_flu_encounter, end_flu_encounter) + 
      in_range(measure.encounter_prev_med_40_or_older, start_flu_encounter, end_flu_encounter) + 
      in_range(measure.encounter_prev_med_group, start_flu_encounter, end_flu_encounter) + 
      in_range(measure.encounter_prev_med_ind, start_flu_encounter, end_flu_encounter) + 
      in_range(measure.encounter_prev_med_other, start_flu_encounter, end_flu_encounter) + 
      in_range(measure.encounter_nursing, start_flu_encounter, end_flu_encounter) + 
      in_range(measure.encounter_nursing_discharge, start_flu_encounter, end_flu_encounter); 
    return (flu_encounters>0);
  }
  
  var numerator = function(patient) {
    // should this be start_flu -> end_flu instead ?
    return in_range(measure.immunization, earliest_encounter, effective_date);
  }
  
  var exclusion = function(patient) {
    return measure.allergy_to_eggs ||
      measure.immunization_allergy ||
      measure.immunization_adverse_event ||
      measure.immunization_intolerance ||
      measure.immunization_containdication ||
      measure.immunization_declined ||
      measure.patient_reason ||
      measure.medical_reason ||
      measure.system_reason;
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
