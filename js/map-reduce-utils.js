// Adds common utility functions to the root JS object. These are then
// available for use by the map-reduce functions for each measure.
// lib/qme/mongo_helpers.rb executes this function on a database
// connection.
(function() {

  var root = this;

  root.inRange = function(value, min, max) {
    var count = 0;
    if (_.isArray(value)) {
      for (i=0;i<value.length;i++) {
        if ((value[i]>=min) && (value[i]<=max))
          count++;
      }
    } else {
      if ((value>=min) && (value<=max))
        count++;
    }
    return count;
  };
  
  root.map = function(record, population, denominator, numerator, exclusion) {
    var value = {population: [], denominator: [], numerator: [], exclusions: []};
    patient = record._id;
    if (population()) {
      value.population.push(patient);
      if (denominator()) {
        value.denominator.push(patient);
        if (numerator()) {
          value.numerator.push(patient);
        } else if (exclusion()) {
          value.exclusions.push(patient)
          value.denominator.pop();
        }
      }
    }
    emit(null, value);
  };
  
  root.reduce = function (key, values) {
    var total = {population: [], denominator: [], numerator: [], exclusions: []};
    for (var i = 0; i < values.length; i++) {
      total.population = total.population.concat(values[i].population);
      total.denominator = total.denominator.concat(values[i].denominator);
      total.numerator = total.numerator.concat(values[i].numerator);
      total.exclusions = total.exclusions.concat(values[i].exclusions);
    }
    return total;
  };
  
})();
  
