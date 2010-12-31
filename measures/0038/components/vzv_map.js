function () {
  var patient = this;
  var measure = patient.measures["0038"];
  if (measure==null)
    measure={};

  var year = 365 * 24 * 60 * 60;
  var effective_date =  <%= effective_date %>;
  var earliest_birthdate =  effective_date - 2 * year;
  var latest_birthdate =    effective_date - 1 * year;

  // VZV vaccines are considered when they are occurring < 2 years after
  // the patients' birthdate
  var latest_vzv_vaccine = patient.birthdate + 2 * year;

  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }

  // the denominator logic is the same for all of the 0038 reports and this
  // code is defined in the shared library in the project in the code from
  // /js/childhood_immunizations.js
  var denominator = function() {
    return has_outpatient_encounter_with_pcp_obgyn(measure, patient.birthdate, effective_date);
  }

  // To meet the criteria for this report, the patient needs to have either:
  // 1 Chicken Pox (VZV) vaccine up until the time that they are 2 years old,
  // OR resolution on VZV diagnosis by the end of the effective date of this measure
  var numerator = function() {
    number_vzv_vaccine_administered = inRange(measure.vzv_vaccine_administered,
                                              patient.birthdate,
                                              latest_vzv_vaccine);

    return ((number_vzv_vaccine_administered >= 1)
             ||
             (conditionResolved(measure.vzv_diagnosis, patient.birthdate, effective_date)));
  }

  // Exclude patients who have either Lymphoreticular or Histiocytic cancer, or Asymptomatic HIV,
  // or Multiple Myeloma, or Leukemia, or Immunodeficiency, or medication allergy to VZV vaccine
  var exclusion = function() {
    return (inRange(measure.diagnosis_of_cancer_of_lymphoreticular_or_histiocytic_tissue,
                    patient.birthdate,
                    effective_date)
             ||
            inRange(measure.diagnosis_of_asymptomatic_hiv,
                    patient.birthdate,
                    effective_date)
             ||
            inRange(measure.multiple_myeloma_diagnosis,
                    patient.birthdate,
                    effective_date)
             ||
            inRange(measure.leukemia_diagnosis,
                    patient.birthdate,
                    effective_date)
             ||
            inRange(measure.immunodeficiency_diagnosis,
                    patient.birthdate,
                    effective_date)
             ||
            inRange(measure.vzv_vaccine_allergy,
                    patient.birthdate,
                    effective_date));
  }

  map(patient, population, denominator, numerator, exclusion);
};