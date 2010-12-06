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
  
  root.map = function(population, denominator, numerator, exclusion) {
    var value = {i: 0, d: 0, n: 0, e: 0};
    if (population()) {
      value.i++;
      if (denominator()) {
        value.d++;
        if (numerator()) {
          value.n++;
        } else if (exclusion()) {
          value.e++;
          value.d--;
        }
      }
    }
    return value;
  };
  
})();
  
