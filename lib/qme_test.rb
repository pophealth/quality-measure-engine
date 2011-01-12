Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].sort.each do |ext|
  load ext
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r #{File.join(File.dirname(__FILE__),'../spec/spec_helper.rb')}"]
  t.pattern = 'spec/**/m_spec.rb'
end