describe QME::Importer::GenericImporter do

  before(:all) do
    @loader = load_measures
  end

  it "should import the information relevant to determining hypertension blood pressure measurement" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0013/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

    gi = QME::Importer::GenericImporter.new(measure_definition(@loader, '0013'))
    measure_info = gi.parse(doc)

    measure_info['encounter_outpatient'].should include(1270598400)
    measure_info['hypertension'].should include(1262304000)
    measure_info['diastolic_blood_pressure'].should include(942537600)
    measure_info['systolic_blood_pressure'].should include(942537600)
  end

  it "should import the information relevant to determining high blood pressure" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0018/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

    gi = QME::Importer::GenericImporter.new(measure_definition(@loader, '0018'))
    measure_info = gi.parse(doc)

    measure_info['procedures_indicative_of_esrd'].should include(1291939200)
    measure_info['pregnancy'].should include(1291939200)
    measure_info['esrd'].should include (1291939200)
    measure_info['encounter_outpatient'].should include(1239062400)
    measure_info['hypertension'].should include(1258156800)
    measure_info['systolic_blood_pressure'].should include('date' => 1258156800, 'value' => '132')
    measure_info['diastolic_blood_pressure'].should include('date' => 1258156800, 'value' => '86')
  end

  it "should import the the information relevant to determining tobacco use" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0028/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

    gi = QME::Importer::GenericImporter.new(measure_definition(@loader, '0028'))
    measure_info = gi.parse(doc)

    measure_info['individual_counseling_encounter'].should include(1270598400)
    measure_info['tobacco_user'].should include(1262304000)
    measure_info['cessation_agent'].should include(1248825600)
    measure_info['cessation_counseling'].should include(1252454400)
  end

  it "should import the the information relevant to determining cervical cancer screening status" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0032/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

    gi = QME::Importer::GenericImporter.new(measure_definition(@loader, '0032'))
    measure_info = gi.parse(doc)

    measure_info['encounter_outpatient'].should include(1270598400)
    measure_info['pap_test'].should include(1269302400)
    measure_info['hysterectomy'].should be_empty
  end

  it "should import the the information relevant to chlamydia screening" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0033/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

    gi = QME::Importer::GenericImporter.new(measure_definition(@loader, '0033', 'a'))
    measure_info = gi.parse(doc)

    measure_info['encounter_outpatient'].should include(1270598400)
    measure_info['encounter_pregnancy'].should include(1273190400)
    measure_info['contraceptives'].should include(1248825600)
    measure_info['retinoid'].should include(1248825600)
    measure_info['chlamydia_screening'].should include(1269302400)
    measure_info['laboratory_tests_indicative_of_sexually_active_women'].should include(1269302400)
    measure_info['pregnancy_test'].should include(1269302400)
    measure_info['procedures_indicative_of_sexually_active_woman'].should include(1269302400)
  end

  it "should import the the information relevant to determining pneumonia vaccination status" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/0043/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

    gi = QME::Importer::GenericImporter.new(measure_definition(@loader, '0043'))
    measure_info = gi.parse(doc)

    measure_info['vaccination'].should include(1248825600)
    measure_info['encounter'].should include(1270598400)
  end

  it "should import the the information relevant to determining diabetic eye exam measure status" do
    doc = Nokogiri::XML(File.new('fixtures/c32_fragments/diabetes/numerator.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')

    gi = QME::Importer::GenericImporter.new(measure_definition(@loader, '0055'))
    measure_info = gi.parse(doc)

    measure_info['encounter_acute_inpatient'].should include(1275177600)
    measure_info['encounter_non_acute_inpatient'].should include(1275177600)
    measure_info['encounter_outpatient'].should include(1275177600)
    measure_info['encounter_outpatient_opthamological_services'].should include(1275177600)
    measure_info['medications_indicative_of_diabetes'].should include(1275177600)
    measure_info['diagnosis_diabetes'].should include(1275177600)
    measure_info['diagnosis_gestational_diabetes'].should include(1275177600)
    measure_info['diagnosis_steroid_induced_diabetes'].should include(1275177600)
    measure_info['polycystic_ovaries'].should include(1275177600)
    measure_info['proceedure_eye_exam'].should include(1275177600)
  end

end