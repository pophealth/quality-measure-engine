# Validate the measure specifications and patient samples

require 'json'

describe JSON, 'All measure specifications' do
  it 'should be valid JSON' do
    Dir.glob('measures/*/*.json').each do |measure_file|
      measure = File.read(measure_file)
      json = JSON.parse(measure)
    end
  end
end

describe JSON, 'All patient samples' do
  it 'should be valid JSON' do
    Dir.glob('measures/*/patients/*.json').each do |measure_file|
      measure = File.read(measure_file)
      json = JSON.parse(measure)
    end
  end
end
