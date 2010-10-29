require 'rspec/core/rake_task'

Dir['lib/tasks/*.rake'].sort.each do |ext|
  load ext
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end
