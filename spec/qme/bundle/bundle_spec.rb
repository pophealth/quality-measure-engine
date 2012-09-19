require 'pry'

describe QME::Bundle do
  before do

  end
  
  it 'Should drop all collections' do
    binding.pry
    
    @db['bundles'] << {}
    @db['measures'] << {}
    @db['selected_measures'] << {}
    @db['patient_cache'] << {}
    @db['query_cache'] << {}

    @db['bundles'].count.must_equal 1
    @db['measures'].count.must_equal 1
    @db['selected_measures'].count.must_equal 1
    @db['patient_cache'].count.must_equal 1
    @db['query_cache'].count.must_equal 1

    QME::Bundle.drop_collections

    @db['bundles'].count.must_equal 0
    @db['measures'].count.must_equal 0
    @db['selected_measures'].count.must_equal 0
    @db['patient_cache'].count.must_equal 0
    @db['query_cache'].count.must_equal 0
  end
end