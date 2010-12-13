function () {
  var patient = this;
  var measure = patient.measures["0028"];
  if (measure==null)
    measure={};

  var year = 365*24*60*60;
  var effective_date = <%= effective_date %>;
  var latest_birthdate = effective_date - 18*year;
  var earliest_encounter = effective_date - 2*year;
  var latest_encounter = effective_date - 1*year;
  
  var population = function() {
	other_encounters = 
	  inRange(measure.behavior_encounter, earliest_encounter, effective_date) +
	  inRange(measure.occupational_therapy_encounter, earliest_encounter, effective_date) +
	  inRange(measure.office_encounter, earliest_encounter, effective_date) +
	  inRange(measure.psychiatric_encounter, earliest_encounter, effective_date);
    preventive_encounters = 
      inRange(measure.adult_preventive_med_encounter, latest_encounter, effective_date) +
      inRange(measure.other_preventive_med_encounter, latest_encounter, effective_date) +
      inRange(measure.individual_counseling_encounter, latest_encounter, effective_date) +
      inRange(measure.group_counseling_encounter, latest_encounter, effective_date);
    return (patient.birthdate<=latest_birthdate && (other_encounters>1 || preventive_encounters>0));
  }
  
  var denominator = function() {
    return inRange(measure.tobacco_user, earliest_encounter, effective_date);
  }
  
  var numerator = function() {
    cessation_procedure = inRange(measure.cessation_counseling, earliest_encounter, effective_date);
    cessation_medication = inRange(measure.cessation_agent, earliest_encounter, effective_date);
    return (cessation_procedure || cessation_medication);
  }
  
  var exclusion = function() {
    return false;
  }
  
  map(patient, population, denominator, numerator, exclusion);
};