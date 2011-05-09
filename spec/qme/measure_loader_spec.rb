describe QME::Measure::Loader do
  before do
    @measure_def_dir = File.join('fixtures', 'measure_defs', 'sample_single_from_multi_xls')
  end
  
  it 'Should load the sample measure correctly' do
    measure = QME::Measure::Loader.load_measure(@measure_def_dir)
    measure = measure[0]
    measure['measure'].should have_key('eyes')
    measure['measure'].should have_key('esrd_diagnosis_active')
  end
end