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

  // IPV vaccines are considered when they are occurring >= 42 days and 
  // < 2 years after the patients' birthdate
  var earliest_ipv_vaccine = patient.birthdate + 42 * day;
  var latest_ipv_vaccine =   patient.birthdate + 2  * year;

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
    number_ipv_vaccine_administered = inRange(measure.ipv_vaccine_administered, 
                                              earliest_ipv_vaccine, 
                                              latest_ipv_vaccine);

    // patient needs 3 different polio (IPV) vaccines from the time that they are 42 days old, 
    // until the time that they are 2 years old
    return ((number_ipv_vaccine_administered >= 3) && 
            // The patient cannot have either:
            // IPV vaccine allergy 
            // OR neomycin allergy
            // OR streptomycin allergy
            // OR polymyxin allergy
            //
            // NOTE that this might belong in the exclusion logic
            // and will be discussed with NCQA in the future
            !((inRange(measure.ipv_vaccine_allergy,  patient.birthdate, effective_date))
              ||
              (inRange(measure.neomycin_allergy,     patient.birthdate, effective_date))
              ||
              (inRange(measure.streptomycin_allergy, patient.birthdate, effective_date))
              ||
              (inRange(measure.polymyxin_allergy,    patient.birthdate, effective_date))));
  }

  // no exclusions defined for any reports that are a part of NQF 0038
  var exclusion = function() {
    return false;
  }

  map(patient, population, denominator, numerator, exclusion);
};