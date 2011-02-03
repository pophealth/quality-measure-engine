// Adds common utility functions to the root JS object. These are then
// available for use by the map-reduce functions for each measure.
// lib/qme/mongo_helpers.rb executes this function on a database
// connection.
(function() {

  var root = this;

  // returns the number of values which fall between the supplied limits
  // value may be a number or an array of numbers
  root.inRange = function(value, min, max) {
    if (!_.isArray(value))
      value = [value];
    var count = 0;
    for (i=0;i<value.length;i++) {
      if ((value[i]>=min) && (value[i]<=max))
        count++;
    }
    return count;
  };
  
  // returns the largest member of value that is within the supplied range
  root.maxInRange = function(value, min, max) {
    if (value==null)
      return null;
    allInRange = _.select(value, function(v) {return v>=min && v<=max;});
    return _.max(allInRange);
  }
  
  // returns the number of values which are less than the supplied limit
  // value may be a number or an array of numbers
  root.lessThan = function(value, max) {
    if (!_.isArray(value))
      value = [value];
    var count = 0;
    for (i=0;i<value.length;i++) {
      if (value[i]<=max)
        count++;
    }
    return count;
  };
  
  // Returns the a boolean true when any entry within conditions[i].end is 
  // ever less than the endDate. If no conditions meet this criteria, this
  // function always returns false
  root.conditionResolved = function(conditions, startDate, endDate) {
    if (conditions) {
      return _.any(conditions, function(condition) {
          return inRange(condition.end, startDate, endDate) > 0;
      });
    } else {
      return false
    };
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
  
  // Returns the number of actions that occur within the specified time period of
  // something. The first two arguments are arrays or single-valued time stamps in
  // seconds-since-the-epoch, timePeriod is in seconds.
  root.actionFollowingSomething = function(something, action, timePeriod) {
    if (!_.isArray(something))
      something = [something];
    if (!_.isArray(action))
      action = [action];
    
    var result = 0;
    for (i=0; i<something.length; i++) {
      timeStamp = something[i];
      for (j=0; j<action.length;j++) {
        if (action[j]>=timeStamp && (action[j] <= (timeStamp+timePeriod)))
          result++;
      }
    }
    
    return result;
  }
    
  // Returns the number of actions that occur after
  // something. The first two arguments are arrays or single-valued time stamps in
  // seconds-since-the-epoch.
  root.actionAfterSomething = function(something, action) {
    if (!_.isArray(something))
      something = [something];
    if (!_.isArray(action))
      action = [action];
   
    var result = 0;
    for (i=0; i<something.length; i++) {
      timeStamp = something[i];
      for (j=0; j<action.length;j++) {
        if (action[j]>=timeStamp )
          result++;
      }
    }
    return result;
  }
  
  // Returns all members of the values array that fall between min and max inclusive
  root.selectWithinRange = function(values, min, max) {
    return _.select(values, function(value) { return value<=max && value>=min; });
  }
    
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
