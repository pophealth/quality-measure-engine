describe QME::Importer::CodeSystemHelper do
  it "should find the code system for an OID" do
    QME::Importer::CodeSystemHelper.code_system_for('2.16.840.1.113883.6.1').should == 'LOINC'
  end
  
  it "should find the OID for a code system" do
    QME::Importer::CodeSystemHelper.oid_for_code_system('LOINC').should == '2.16.840.1.113883.6.1'
  end
  
  it "should be able to return the whole codeset" do
    cs = QME::Importer::CodeSystemHelper.code_systems
    cs['2.16.840.1.113883.6.1'].should == 'LOINC'
  end
end