describe QME::Importer::HL7Helper do
  
  it 'should be able to properly convert an HL7 timestamp' do
    ts = QME::Importer::HL7Helper.timestamp_to_integer('20100821')
    ts.should == Time.gm(2010, 8, 21).to_i
  end
  
end