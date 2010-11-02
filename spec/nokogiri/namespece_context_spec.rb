describe Nokogiri::NamespaceContext do
  before do
    fixture_file = File.new('fixtures/allergy1.xml')
    ng = Nokogiri::XML(fixture_file)
    @ctx = Nokogiri::NamespaceContext.new(ng.root, 'a' => 'http://projecthdata.org/hdata/schemas/2009/06/allergy',
        'core' => 'http://projecthdata.org/hdata/schemas/2009/06/core')
  end
  
  it 'should find a single node' do
    allergy_type = @ctx.first('/a:allergy/a:type')
    allergy_type.should_not be_nil
    allergy_type.attr('codeSystem').should == 'SNOMEDCT'
  end
  
  it 'should find a node set' do
    address = @ctx.evaluate('/a:allergy/core:informationSource/core:author/core:address')
    address.should_not be_nil
    address.should have(2).items
  end
  
  it 'should return nil when it can not find something' do
    foo = @ctx.first('/a:foo')
    foo.should be_nil
  end
end