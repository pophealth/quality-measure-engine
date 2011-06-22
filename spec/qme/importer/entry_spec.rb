describe QME::Importer::Entry do
  before do
    @measures = File.join('fixtures', 'entry', 'sample.json')
    raw_measure_json = File.read(@measures)
    @measure_json = JSON.parse(raw_measure_json)
  end

  it "should claim it is useable if it has a code an date" do
    entry = QME::Importer::Entry.new
    entry.time = 1270598400
    entry.add_code("314443004", "SNOMED-CT")
    entry.usable?.should be_true
  end

  it "shouldn't claim it is useable if it doesn't have a time" do
    entry = QME::Importer::Entry.new
    entry.add_code("314443004", "SNOMED-CT")
    entry.usable?.should be_false
  end

  it "shouldn't claim it is useable if it doesn't have a code" do
    entry = QME::Importer::Entry.new
    entry.time = 1270598400
    entry.usable?.should be_false
  end

  it "should be able to tell if it has a code in a code set" do
    entry = QME::Importer::Entry.new
    entry.add_code("854935", "RxNorm")
    entry.add_code("44556699", "RxNorm")
    entry.add_code("1245", "Junk")
    entry.is_in_code_set?(@measure_json['measure']['vaccination']['codes']).should be_true
  end

  it "should be able to tell if it does not have a code in a code set" do
    entry = QME::Importer::Entry.new
    entry.add_code("44556699", "RxNorm")
    entry.add_code("1245", "Junk")
    entry.is_in_code_set?(@measure_json['measure']['vaccination']['codes']).should be_false
  end
  
  it "should be able to convert itself to a Hash" do
    entry = QME::Importer::Entry.new
    entry.add_code("44556699", "RxNorm")
    entry.time = 1270598400
    
    h = entry.to_hash
    h['time'].should == 1270598400
    h['codes']['RxNorm'].should include('44556699')
  end
end