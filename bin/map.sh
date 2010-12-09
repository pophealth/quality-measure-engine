#!/bin/bash
# Usage debug measure_file patient_file
# $RHINO_HOME should be the absolute path of your Mozilla Rhino install 
# directory
java -cp $RHINO_HOME/js.jar org.mozilla.javascript.tools.shell.Main bin/loadmeasure.js $1 $2
