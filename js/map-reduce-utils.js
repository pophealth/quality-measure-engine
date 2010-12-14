// Adds common utility functions to the root JS object. These are then
// available for use by the map-reduce functions for each measure.
// lib/qme/mongo_helpers.rb executes this function on a database
// connection.
(function() {

  var root = this;

  // returns the number of values which fall between the supplied limits
  // value may be a number or an array of numbers
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
  
  // Returns the minimum of readings[i].value where readings[i].date is in
  // the supplied startDate and endDate. If no reading meet this criteria,
  // returns defaultValue.
  root.minValueInDateRange = function(readings, startDate, endDate, defaultValue) {
    var readingInDateRange = function(reading) {
      result = inRange(reading.date, startDate, endDate);
      return result;
    };
    
    if (!readings || readings.length<1)
      return defaultValue;
  
    allInDateRange = _.select(readings, readingInDateRange);
    min = _.min(allInDateRange, function(reading) {return reading.value;});
    if (min)
      return min.value;
    else
      return defaultValue;
  };
    
  // Returns the most recent readings[i].value where readings[i].date is in
  // the supplied startDate and endDate. If no reading meet this criteria,
  // returns defaultValue.
  root.latestValueInDateRange = function(readings, startDate, endDate, defaultValue) {
    var readingInDateRange = function(reading) {
      result = inRange(reading.date, startDate, endDate);
      return result;
    };
    
    if (!readings || readings.length<1)
      return defaultValue;
  
    allInDateRange = _.select(readings, readingInDateRange);
    latest = _.max(allInDateRange, function(reading) {return reading.date;});
    if (latest)
      return latest.value;
    else
      return defaultValue;
  };
    
  root.map = function(record, population, denominator, numerator, exclusion) {
    var value = {population: [], denominator: [], numerator: [], exclusions: [], antinumerator: []};
    patient = record._id;
    if (population()) {
      value.population.push(patient);
      if (denominator()) {
        value.denominator.push(patient);
        if (numerator()) {
          value.numerator.push(patient);
        } else if (exclusion()) {
          value.exclusions.push(patient);
          value.denominator.pop();
        } else {
          value.antinumerator.push(patient);
        }
      }
    }
    emit(null, value);
  };

  root.reduce = function (key, values) {
    var total = {population: [], denominator: [], numerator: [], exclusions: [], antinumerator: []};
    for (var i = 0; i < values.length; i++) {
      total.population = total.population.concat(values[i].population);
      total.denominator = total.denominator.concat(values[i].denominator);
      total.numerator = total.numerator.concat(values[i].numerator);
      total.exclusions = total.exclusions.concat(values[i].exclusions);
      total.antinumerator = total.antinumerator.concat(values[i].antinumerator);
    }
    return total;
  };

})();
