function () {
  var patient = this;
  var measure = patient.measures["0036"];
  if (measure==null)
    measure={};

  
  var day = 24*60*60;
  var year = 365*day;
  var effective_date = <%= effective_date %>;
  var earliest_birthdate = effective_date - 50*year;
  var latest_birthdate = effective_date - 5*year;
  var earliest_encounter = effective_date - 1*year;

  var antiasmathic_med = inRange(measure.antiasthmatic_combinations, earliest_encounter, effective_date);
  var antibody_med = inRange(measure.antibody_inhibitor, earliest_encounter, effective_date);
  var corticosteroid_med = inRange(measure.inhaled_corticosteroids, earliest_encounter, effective_date);
  var steroid_med = inRange(measure.inhaled_steroid_combinations, earliest_encounter, effective_date);
  var leukotriene_med = inRange(measure.leukotriene_inhibitors, earliest_encounter, effective_date);
  var mast_cell_med = inRange(measure.mast_cell_stabilizer, earliest_encounter, effective_date);
  var methylxanthine_med = inRange(measure.methylxanthines, earliest_encounter, effective_date);
  
  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }
  
  var denominator = function() {
    ed_encounter = inRange(measure.encounter_ed, earliest_encounter, effective_date);
    asthma = inRange(measure.asthma, earliest_encounter, effective_date);
    acute_inpt_encounter = inRange(measure.encounter_acute_inpt, earliest_encounter, effective_date);
    all_encounters = inRange(measure.encounter_outpatient_acute_inpatient_ed, earliest_encounter, effective_date);
    long_acting_beta_med = inRange(measure.long_acting_inhaled_beta_2_agonist, earliest_encounter, effective_date);
    short_acting_beta_med = inRange(measure.short_acting_beta_2_agonist, earliest_encounter, effective_date);
    
    return (ed_encounter && asthma) || 
      (acute_inpt_encounter && asthma) || 
      (all_encounters >= 4 && asthma && 
	    ((antiasmathic_med+antibody_med+corticosteroid_med+steroid_med+leukotriene_med+
	    long_acting_beta_med + mast_cell_med + methylxanthine_med + short_acting_beta_med) >= 2)) || 
	  ((antiasmathic_med + antibody_med + corticosteroid_med + steroid_med + leukotriene_med + 
		long_acting_beta_med + mast_cell_med + methylxanthine_med + short_acting_beta_med) >= 4) || 
	  (leukotriene_med >= 4 && asthma);
  }
  
  var numerator = function() {
    return (antiasmathic_med || antibody_med || corticosteroid_med || steroid_med || leukotriene_med || mast_cell_med || methylxanthine_med);
  }
  
  var exclusion = function() {
    return measure.copd ||
      measure.cystic_fibrosis ||
      measure.emphysema ||
      measure.acute_respiratory_failure;
  }
  
  map(patient, population, denominator, numerator, exclusion);
};