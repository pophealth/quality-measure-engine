describe QME::MapReduce::Executor do

  before do
    @loader = QME::Database::Loader.new('test')
  end
  
  it 'should map patients as expected' do
    validate_patient_mapping(@loader)
  end
  
end
