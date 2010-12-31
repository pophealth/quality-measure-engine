function () {
  var patient = this;
  var measure = patient.measures["0038"];
  if (measure==null)
    measure={};

  var year = 365 * 24 * 60 * 60;;
  var effective_date =  <%= effective_date %>;
  var earliest_birthdate =  effective_date - 2 * year;
  var latest_birthdate =    effective_date - 1 * year;

  // Hepatitis A vaccines are considered when they are occurring < 2 years after
  // the patients' birthdate
  var latest_hep_a_vaccine = patient.birthdate + 2 * year;

  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }

  // the denominator logic is the same for all of the 0038 reports and this
  // code is defined in the shared library in the project in the code from
  // /js/childhood_immunizations.js
  var denominator = function() {
    return has_outpatient_encounter_with_pcp_obgyn(measure, patient.birthdate, effective_date);
  }

  // To meet the criteria for this report, the patient needs either:
  // 2 different Hepatitis A (Hep A) vaccines until the time that they are 2 years old,
  // OR resolution on a hepatitis A diagnosis by the end of the effective date
  var numerator = function() {
    number_hep_a_vaccine_administered = inRange(measure.hepatitis_a_vaccine_administered,
                                                patient.birthdate,
                                                latest_hep_a_vaccine);

    return ((number_hep_a_vaccine_administered >= 2)
              ||
             (conditionResolved(measure.hepatitis_a_diagnosis, patient.birthdate, effective_date)));
  }

  // Exclude patients who have an allergy to hepatitis A vaccine
  var exclusion = function() {
    return (inRange(measure.hepatitis_a_vaccine_allergy, patient.birthdate, effective_date));
  }

  map(patient, population, denominator, numerator, exclusion);
};