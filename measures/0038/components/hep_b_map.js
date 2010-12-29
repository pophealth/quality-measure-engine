function () {
  var patient = this;
  var measure = patient.measures["0038"];
  if (measure==null)
    measure={};

  var day = 24 * 60 * 60;
  var year = 365 * day;
  var effective_date =  <%= effective_date %>;
  var earliest_birthdate =  effective_date - 2 * year;
  var latest_birthdate =    effective_date - 1 * year;

  // dtap vaccines are considered when they are occurring < 2 years after 
  // the patients' birthdate
  var latest_hep_b_vaccine =   patient.birthdate + 2  * year;

  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }

  // the denominator logic is the same for all of the 0038 reports and this 
  // code is defined in the shared library in the project in the code from 
  // /js/childhood_immunizations.js
  var denominator = function() {
    return has_outpatient_encounter_with_pcp_obgyn(measure, patient.birthdate, effective_date);
  }

  var numerator = function() {
    number_hep_b_vaccine_administered = inRange(measure.hepatitis_b_vaccine_administered, 
                                                patient.birthdate, 
                                                latest_hep_b_vaccine);

    // To meet the criteria for this report, the patient needs either:
    // 3 different Hepatitis B (Hep B) vaccines until the time that they are 2 years old, 
    // OR resolution on a hepatitis B diagnosis by the end of the effective date of this measure
    // AND the patients cannot have either an allergy to either Baker's yeast, or an allergy 
    // to Hepatitis B vaccine
    return (((number_hep_b_vaccine_administered >= 3) 
              ||
             (conditionResolved(measure.hepatitis_b_diagnosis, patient.birthdate, effective_date)))
            &&
            !(inRange(measure.allergy_to_bakers_yeast,         patient.birthdate, effective_date)
              ||
             inRange(measure.hepatitis_b_vaccine_allergy,      patient.birthdate, effective_date)));
  }

  // no exclusions defined for any reports that are a part of NQF 0038
  var exclusion = function() {
    return false;
  }

  map(patient, population, denominator, numerator, exclusion);
};