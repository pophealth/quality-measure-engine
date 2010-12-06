function () {
  var year = 365*24*60*60;
  var effective_date = <%= @effective_date %>;
  var latest_birthdate = effective_date - 18*year;
  var earliest_birthdate = effective_date - 65*year;
  var earliest_encounter = effective_date - year;
  var measure = this.measures["0421"];
  if (measure==null)
    measure={};
  
  var population = function(patient) {
    correct_age = inRange(patient.birthdate, earliest_birthdate, latest_birthdate);
    return (correct_age);
  }
  
  var denominator = function(patient) {
    return inRange(measure.encounter, earliest_encounter, effective_date);
  }
  
  var numerator = function(patient) {
    if (measure.encounter==null)
      return false;
    for(i=0;i<measure.encounter.length;i++) {
      encounter_date = measure.encounter[i];
      earliest_bmi = encounter_date - year/2;
      if (measure.bmi==null)
        return false;
      for (j=0;j<measure.bmi.length;j++) {
        bmi = measure.bmi[j];
        if (inRange(bmi.date, earliest_bmi, encounter_date)) {
          if (bmi.value>=18.5 && bmi.value<25)
            return true;
          else if (measure.dietary_consultation_order!=null && measure.dietary_consultation_order.length>0)
            return true;
          else if (measure.bmi_management!=null && measure.bmi_management.length>0)
            return true;
        }
      }
    }
    return false;
  }
  
  var exclusion = function(patient) {
    pregnant = inRange(measure.pregnancy, earliest_encounter, effective_date);
    return pregnant || measure.physical_exam_not_done || measure.terminal_illness;
  }
  
  var value = {i: 0, d: 0, n: 0, e: 0};
  if (population(this)) {
    value.i++;
    if (denominator(this)) {
      value.d++;
      if (numerator(this)) {
        value.n++;
      } else if (exclusion(this)) {
        value.e++;
        value.d--;
      }
    }
  }
  emit(null, value);
};