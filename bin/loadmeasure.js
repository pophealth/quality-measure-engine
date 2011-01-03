var mockOutput = {}; // Place holder for the result of the map function

// Mock the emit function since we don't have the full MongoDB environment
var emit = function(key, value) {
  mockOutput[key] = value;
}

// Load up Underscore.js
load("js/underscore-min.js");
load("js/map-reduce-utils.js");
load("js/diabetes-utils.js");

// Read in the map function JavaScript
var rawMeasure = readFile(arguments[0]);

// Evaluate it with an effective_date
var populatedMeasure = _.template(rawMeasure, {"effective_date": 1284854400}); // September 19th, 2010
eval("var map_fn = " + populatedMeasure);

// Grab a patient record
var recordString = readFile(arguments[1]);
eval("var record = " + recordString);

// Bind the map function to the patient record. This ensures "this" will be properly set in the map function
var boundMap = _.bind(map_fn, record);

boundMap();

print("Population: " +  mockOutput[null].population.length.toString());
print("Denominator: " + mockOutput[null].denominator.length.toString());
print("Numerator: " +   mockOutput[null].numerator.length.toString());
print("Exclusions: " +  mockOutput[null].exclusions.length.toString());