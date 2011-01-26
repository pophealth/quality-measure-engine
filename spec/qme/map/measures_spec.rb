describe QME::MapReduce::Executor do

  before do
    @loader = QME::Database::Loader.new('test')
    QME::MongoHelpers.initialize_additional_frameworks(@loader.get_db,'./js')
    if ENV['MEASURE_DIR']
      @measures = Dir.glob(File.join(ENV['MEASURE_DIR'], '*'))
    else
      @measures = Dir.glob(File.join('measures', '*'))
    end
  end
  
  it 'should produce the expected results for each measure' do
    validate_measures(@measures,@loader)
  end
  
end
