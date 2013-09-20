// Adds common utility functions to the root JS object. These are then
// available for use by the map-reduce functions for each measure.
// lib/qme/mongo_helpers.rb executes this function on a database
// connection.

var root = this;

root.map = function(record, population, denominator, numerator, exclusion, denexcep) {
  var value = {IPP: 0, DENOM: 0, NUMER: 0, DENEXCEP: 0,
               DENEX: 0, antinumerator: 0, patient_id: record._id,
               medical_record_id: record.medical_record_number,
               first: record.first, last: record.last, gender: record.gender,
               birthdate: record.birthdate, test_id: record.test_id,
               provider_performances: record.provider_performances,
               race: record.race, ethnicity: record.ethnicity, languages: record.languages};
  var ipp = population()
  if (Specifics.validate(ipp)) {
    value.IPP = 1;
    if (Specifics.validate(denexcep(), ipp)) {
      value.DENEXCP = 1;
    } else {
      denom = denominator();
      if (Specifics.validate(denom, ipp)) {
        value.DENOM = 1;
        numer = numerator()
        if (Specifics.validate(numer, denom, ipp)) {
          value.NUMER = 1;
        } else { 
          excl = exclusion()
          if (Specifics.validate(excl, denom, ipp)) {
            value.DENEX = 1;
            value.DENOM = 0;
          } else {
            value.antinumerator = 1;
          }
        }
      }
    }
  }


  if (typeof Logger != 'undefined') value['logger'] = Logger.logger
  
  value.measure_id = hqmfjs.hqmf_id
  value.sub_id = hqmfjs.sub_id
  value.nqf_id = hqmfjs.nqf_id
  value.test_id = hqmfjs.test_id
  value.effective_date = hqmfjs.effective_date;

  emit(ObjectId(), value);
};
