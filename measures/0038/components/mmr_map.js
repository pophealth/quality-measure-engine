function () {
  var patient = this;
  var measure = patient.measures["0038"];
  if (measure==null)
    measure={};

  var year = 365 * 24 * 60 * 60;
  var effective_date =  <%= effective_date %>;
  var earliest_birthdate =  effective_date - 2 * year;
  var latest_birthdate =    effective_date - 1 * year;

  // Measles, Mumps and Rubella (MMR) vaccines are considered when they are occur
  // < 2 years after the patients' birthdate
  var latest_mmr_vaccine =   patient.birthdate + 2 * year;

  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }

  // the denominator logic is the same for all of the 0038 reports and this
  // code is defined in the shared library in the project in the code from
  // /js/childhood_immunizations.js
  var denominator = function() {
    return has_outpatient_encounter_with_pcp_obgyn(measure, patient.birthdate, effective_date);
  }

  // patient needs 1 Measles, Mumps and Rubella (MMR) vaccine prior to 2 years old
  // or needs to address measles, mumpls, and rubella independantly through vaccine,
  // resolved condition, or allergy to individual vaccine
  var numerator = function() {
    number_mmr_vaccine_administered =     inRange(measure.mmr_vaccine_administered,
                                                  patient.birthdate,
                                                  latest_mmr_vaccine);
    number_measles_vaccine_administered = inRange(measure.measles_vaccine_administered,
                                                  patient.birthdate,
                                                  latest_mmr_vaccine);
    number_mumps_vaccine_administered =   inRange(measure.mumps_vaccine_administered,
                                                  patient.birthdate,
                                                  latest_mmr_vaccine);
    number_rubella_vaccine_administered = inRange(measure.rubella_vaccine_administered,
                                                  patient.birthdate,
                                                  latest_mmr_vaccine);

           // either get the MMR vaccine at least once and meet the criteria...
    return ((number_mmr_vaccine_administered >= 1)
            ||
            // or... address measles vaccines, resolution, or allergy
            (((number_measles_vaccine_administered >= 1) 
               ||
              (conditionResolved(measure.measles, patient.birthdate, effective_date))
               ||
              (inRange(measure.measles_vaccine_allergy, patient.birthdate, effective_date)))
             &&
             // and then address mumps vaccines, resolution, or allergy
             ((number_mumps_vaccine_administered >= 1)
               ||
              (conditionResolved(measure.mumps, patient.birthdate, effective_date))
               ||
              (inRange(measure.mumps_vaccine_allergy, patient.birthdate, effective_date)))
             &&
             // and then address rubells vaccines, resolution, or allergy...
             ((number_rubella_vaccine_administered >= 1)
               ||
              (conditionResolved(measure.rubella, patient.birthdate, effective_date))
               ||
              (inRange(measure.rubella_vaccine_allergy, patient.birthdate, effective_date)))));
  }

  // Exclude patients who have either Lymphoreticular or Histiocytic cancer, or Asymptomatic HIV,
  // or Multiple Myeloma, or Leukemia, or Immunodeficiency, or medication allergy to MMR vaccine
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
            inRange(measure.mmr_vaccine_allergy,
                    patient.birthdate,
                    effective_date));
  }

  map(patient, population, denominator, numerator, exclusion);
};