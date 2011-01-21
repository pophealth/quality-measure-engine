describe QME::MapReduce::Executor do
 bundle_dir = File.join(File.dirname(__FILE__),'../../fixtures/bundle')
  before do
    @loader = QME::Database::Loader.new('test')
    @loader.get_db.drop_collection('measures')
    @loader.get_db.drop_collection('bundles')
  end
  
  it 'Should be able to load a bundle' do
    bundle = @loader.save_bundle(bundle_dir, 'bundles')
    bundle[:measures].length.should == 1
    bundle[:bundle_data][:extensions].length.should == 1
    bundle[:bundle_data]['name'].should == "test_bundle"
    @loader.get_db['bundles'].count.should == 1
    @loader.get_db['bundles'].find_one['name'].should == 'test_bundle'
  end
  
  
  it 'should be able to load a bundle' do
    
    
  end
  
  
  it 'should be able to remove a bundle' do 
    bundle = @loader.save_bundle(bundle_dir, 'bundles')
    bundle_measures_count = bundle[:measures].length
    @loader.get_db['bundles'].count.should == 1
    measures = @loader.get_db['measures'].count
    
    @loader.remove_bundle(bundle[:bundle_data]['_id'])
    @loader.get_db['bundles'].count.should == 0
    measures = @loader.get_db['measures'].count.should == (measures - bundle_measures_count)
    
    
  end
  
  it 'should be able to create a bundle' do
    
    
  end
  
  
 end
