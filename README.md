Quality Measure Engine
----------------------

This project is a library designed to calculate clinical quality measures over a given population. Quality measures are described via JSON and provide the details on what information is needed from a patient record to calculate a quality measure. The logic of the measure is described in JavaScript using the MapReduce algorithmic framework.

Calculating Quality Measures
----------------------------

Results of quality measures are represented by QME::QualityReport. This class provides ways to determine if a report has been calculated for a population in the database as well as ways to create jobs to run the calculations.

Environment
===========

This project currently uses Ruby 2.1.X and is built using [Bundler](http://gembundler.com/). To get all of the dependencies for the project, first install bundler:

    gem install bundler

Then run bundler to grab all of the necessary gems:

    bundle install

The Quality Measure engine relies on a MongoDB [MongoDB](http://www.mongodb.org/) running a minimum of version 2.6.* or higher.  To get and install Mongo refer to:

    http://www.mongodb.org/display/DOCS/Quickstart

Testing
=======

This project uses [minitest](https://github.com/seattlerb/minitest) for testing. To run the suite, just enter the following:

    bundle exec rake test

The coverage of the test suite is monitored with [simplecov](https://github.com/colszowka/simplecov). You can see the code coverage by looking in the coverage directory after running the test suite

Project Practices
=================

Please try to follow the [GitHub Coding Style Guides](https://github.com/styleguide). Additionally, we are switching to the git workflow described in [Juan Batiz-Benet's Gist](https://gist.github.com/jbenet/ee6c9ac48068889b0912). If you are new to the project and would like to make changes, please fork and do your work in a feature branch. Submit a pull request and we'll check to see if it is suitable to be merged in.

License
=======

Copyright 2014 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
