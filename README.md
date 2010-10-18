This project will provide a library that can ingest HITSP C32's and ASTM CCR's and extract values needed to compute heath quality measures for a population. It will then be able to query over a population to compute how many people within a population conform to the measure.

Environment
-----------

This project currently uses Ruby 1.9.2 and is built using [Bundler](http://gembundler.com/). To get all of the dependencies for the project, first install bundler:

    gem install bundler

Then run bundler to grab all of the necessay gems:

    bundle install

Testing
-------

This project uses [RSpec](http://github.com/rspec/rspec-core) for testing. To run the suite, just enter the following:

    rake spec
