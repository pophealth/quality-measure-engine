require 'ap'

describe QME::Measure::PropertiesBuilder do
  before do
    @json_file = File.join('fixtures', 'measure_props', 'props2.xlsx.json')
    @properties = JSON.parse(File.read(@json_file))
  end
  
  it 'Should patch the definition' do
    @properties['N_1810']['value'].should be_nil
    patched_properties = QME::Measure::PropertiesBuilder.patch_properties(@properties, @json_file)
    patched_properties['N_1810']['value'].should have_key('type')
    patched_properties['N_1472']['group_type'].should eql('abstract')
  end
  
  it 'Should group properties' do
    @properties.values.select { |value| value['standard_concept_id']=='N_c102' }.should_not be_empty
    patched_properties = QME::Measure::PropertiesBuilder.patch_properties(@properties, @json_file)
    grouped_properties = QME::Measure::PropertiesBuilder.build_groups(patched_properties)
    grouped_properties.select { |key| key['standard_concept_id']=='N_c102' }.should be_empty
    grouped_properties.select { |key| key['standard_concept_id']=='N_c190' }.should_not be_empty
  end
  
  it 'Should create the expected properties' do
    result = QME::Measure::PropertiesBuilder.build_properties(@properties, @json_file)
    result['measure'].should have_key('diastolic_blood_pressure_physical_exam_finding')
    result['measure']['diastolic_blood_pressure_physical_exam_finding'].should have_key('standard_concept')
    result['measure']['diastolic_blood_pressure_physical_exam_finding']['standard_concept'].should eql('diastolic_blood_pressure')
    result['measure']['diastolic_blood_pressure_physical_exam_finding'].should have_key('standard_category')
    result['measure']['diastolic_blood_pressure_physical_exam_finding']['standard_category'].should eql('physical_exam')
    result['measure']['diastolic_blood_pressure_physical_exam_finding']['items']['type'].should eql('object')
    result['measure']['diastolic_blood_pressure_physical_exam_finding'].should have_key('codes')
    result['measure']['diastolic_blood_pressure_physical_exam_finding']['codes'].length.should eql(1)
    result['measure'].should have_key('encounter_outpatient_encounter')
    result['measure']['encounter_outpatient_encounter']['items']['type'].should eql('number')
    result['measure'].should have_key('esrd_diagnosis_active')
    result['measure']['esrd_diagnosis_active']['standard_category'].should eql('diagnosis_condition_problem')
    result['measure']['esrd_diagnosis_active']['codes'].length.should eql(3)
  end
  
  it 'Should not create the excluded properties' do
    result = QME::Measure::PropertiesBuilder.build_properties(@properties, @json_file)
    result['measure'].select { |key| QME::Measure::PropertiesBuilder::PROPERTIES_TO_IGNORE.include?(key['standard_concept']) }.should be_empty
  end

  it 'Should expand code ranges for CPT codes' do
    result = QME::Measure::PropertiesBuilder.extract_code_values("1, 2-5, 6 ", "SNOMED-CT")
    result.length.should eql(3)
    result.should include("1")
    result.should include("2-5")
    result.should include("6")
    result = QME::Measure::PropertiesBuilder.extract_code_values("1, 2-5, 6 ", "CPT")
    result.length.should eql(6)
    result.should include("1")
    result.should include("2")
    result.should include("3")
    result.should include("4")
    result.should include("5")
    result.should include("6")
  end
end