describe QME::MapReduce::Executor do

  before do
    @loader = QME::Database::Loader.new('test')
    QME::MongoHelpers.initialize_additional_frameworks(@loader.get_db,'./js')
    if ENV['MEASURE_DIR']
      @measures = Dir.glob(File.join(ENV['MEASURE_DIR'], '*'))
    else
      @measures = Dir.glob(File.join('measures', '*'))
    end

    # define custom matchers
    RSpec::Matchers.define :match_population do |population|
      match do |value|
        value == population
      end
    end
    RSpec::Matchers.define :match_denominator do |denominator|
      match do |value|
        value == denominator
      end
    end
    RSpec::Matchers.define :match_numerator do |numerator|
      match do |value|
        value == numerator
      end
    end
    RSpec::Matchers.define :match_exclusions do |exclusions|
      match do |value|
        value == exclusions
      end
    end
  end
  
  it 'should produce the expected results for each measure' do
    validate_measures(@measures,@loader)
  end
  
end
