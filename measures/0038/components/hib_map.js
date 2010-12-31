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

  // HiB vaccines are considered when they are occurring >= 42 days and
  // < 2 years after the patients' birthdate
  var earliest_hib_vaccine = patient.birthdate + 42 * day;
  var latest_hib_vaccine =   patient.birthdate + 2  * year;

  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }

  // the denominator logic is the same for all of the 0038 reports and this
  // code is defined in the shared library in the project in the code from
  // /js/childhood_immunizations.js
  var denominator = function() {
    return has_outpatient_encounter_with_pcp_obgyn(measure, patient.birthdate, effective_date);
  }

  // patient needs 2 different H influenza type B (HiB) vaccines from the time that they 
  // are 42 days old, until the time that they are 2 years old
  var numerator = function() {
    number_hib_vaccine_administered = inRange(measure.h_influenza_type_b_vaccine_administered,
                                              earliest_hib_vaccine,
                                              latest_hib_vaccine);

    return (number_hib_vaccine_administered >= 2);
  }

  // Exclude patients who have an allergy to HiB Vaccine
  var exclusion = function() {
    return (inRange(measure.h_influenza_type_b_vaccine_allergy, patient.birthdate, effective_date));
  }

  map(patient, population, denominator, numerator, exclusion);
};