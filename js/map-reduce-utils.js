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
  
})();
  
