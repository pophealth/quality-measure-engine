This project will provide a library that can ingest HITSP C32's and ASTM CCR's and extract values needed to compute heath quality measures for a population. It will then be able to query over a population to compute how many people within a population conform to the measure.

Environment
-----------

This project currently uses Ruby 1.9.2 and is built using [Bundler](http://gembundler.com/). To get all of the dependencies for the project, first install bundler:

    gem install bundler

Then run bundler to grab all of the necessay gems:

    bundle install

The Quality Measure engine relies on a MongoDB [MongoDB](http://www.mongodb.org/) running a minimum of version 1.6.* or higher.  To get and install Mongo refer to :

	http://www.mongodb.org/display/DOCS/Quickstart

Testing
-------

This project uses [RSpec](http://github.com/rspec/rspec-core) for testing. To run the suite, just enter the following:

    bundle exec rake spec

The coverage of the test suite is monitored with [cover_me](https://github.com/markbates/cover_me) and can be run with:

    bundle exec rake coverage

Map Reduce Testing
------------------

This project used the [MapReduce](http://www.mongodb.org/display/DOCS/MapReduce) functionality of MongoDB pretty heavily.
Debugging JavaScript that is to be run inside of MongoDB can be a bit of a chore, so there is a testing tool that can be run
in your browser to aid in troubleshooting.

The tool is a very small web application based on the [Sinatra](http://www.sinatrarb.com/) framework. It can be run
by executing the following command:

    bundle exec ruby map_test/map_test.rb

After running this command, you can open your browser to [http://localhost:4567](http://localhost:4567). This will show you a page
of measures to choose from. Once you have selected a measure, it will take you to a page where you can choose the map function you
want to test and the effective date you want to run the function with. Once that is selected, you will arrive at the map test page.
The map test page provides the ability to load test JSON records from within the project. Once they are loaded, they can be edited
in the textarea on the page. Finally, if you click the "run" button, it will execute the map function on the record in the text area
and output the results. Since this is executing in a web browser, you can use the JavaScript debugging utilities provided to set
breakpoints and inspect variables.

Source Code Analysis
--------------------

This project uses [metric_fu](http://metric-fu.rubyforge.org/) for source code analysis. Reports can be run with:

    bundle exec rake metrics:all

The project is currently configured to run Flay, Flog, Churn, Reek and Roodi

Project Practices
------------------

Please try to follow our [Coding Style Guides](http://github.com/eedrummer/styleguide). Additionally, we will be using git in a pattern similar to [Vincent Driessen's workflow](http://nvie.com/posts/a-successful-git-branching-model/). While feature branches are encouraged, they are not required to work on the project.
