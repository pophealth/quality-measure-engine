describe QME::MapReduce::Executor do
 bundle_dir = File.join(File.dirname(__FILE__),'../../fixtures/bundle')
  before do
    @loader = QME::Database::Loader.new('test')
  end
  
  it 'Should be able to load a bundle' do
    bundle = @loader.save_bundle(bundle_dir)
    bundle[:measures].length.should == 1
    bundle[:bundle_data][:extensions].length.should == 1
    bundle[:bundle_data]['name'].should == "test_bundle"
  end
end
