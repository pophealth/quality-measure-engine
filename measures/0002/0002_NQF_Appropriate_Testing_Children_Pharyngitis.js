function () {
  var patient = this;
  var measure = patient.measures["0002"];
  if (measure==null)
    measure={};

  var day = 24*60*60;
  var year = 365 * day;
  var effective_date =  <%= effective_date %>;
  var earliest_encounter = effective_date - year;
  var earliest_birthdate =  effective_date - 18 * year;
  var latest_birthdate =    effective_date - 2 * year;

  var population = function() {
    return inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
  }
  
  var denominator = function() {
    var encounters = measure.encounter_ambulatory_including_pediatrics
    if (!inRange(encounters, earliest_encounter, effective_date))
      return false;
    if (!inRange(measure.pharyngitis_diagnosed, earliest_encounter, effective_date))
      return false;
      
    if (!_.isArray(encounters))
      encounters = [encounters];
    var meds = measure.pharyngitis_antibiotics;
    if (!_.isArray(meds))
      meds = [meds];
    
    var result = 0;
    var threeDays = 3 * day;
    var thirtyDays = 30 * day;
    
    var medsThreeAfterAndNotThirtyBefore = function(timeStamp) {
      var match=false;
      for (i=0; i<meds.length;i++) {
        if (meds[i]>=timeStamp && (meds[i] <= (timeStamp+threeDays))) {
          match=true;
          
        } else if (meds[i]<=timeStamp && (meds[i] >= (timeStamp-thirtyDays))) {
          match=false;
          break;
        }
      }
      return match;
    }
    
    var matchingEncounters = _.select(encounters, medsThreeAfterAndNotThirtyBefore);
    measure.encounters_when_prescribed_pharyngitis_antibiotics = matchingEncounters;
    return matchingEncounters.length > 0;
  }

  var numerator = function() {
    return actionFollowingSomething(measure.encounters_when_prescribed_pharyngitis_antibiotics,
      measure.group_a_streptococcus_test, 3*day);
  }

  var exclusion = function() {
    return false;
  }

  map(patient, population, denominator, numerator, exclusion);
};