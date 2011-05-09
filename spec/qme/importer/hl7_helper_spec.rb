describe QME::Importer::HL7Helper do

  it 'should be able to properly convert an HL7 timestamp' do
    ts = QME::Importer::HL7Helper.timestamp_to_integer('20100821')
    ts.should == Time.gm(2010, 8, 21).to_i
  end

  it "should return nil when passed nil" do
    QME::Importer::HL7Helper.timestamp_to_integer(nil).should be_nil
  end

  it "should handle just month and year" do
    ts = QME::Importer::HL7Helper.timestamp_to_integer('201008')
    ts.should == Time.gm(2010, 8).to_i
  end

  it "should handle timestamps specified all the way down to seconds" do
    ts = QME::Importer::HL7Helper.timestamp_to_integer('20100821123022')
    ts.should == Time.gm(2010, 8, 21, 12, 30, 22).to_i
  end

end