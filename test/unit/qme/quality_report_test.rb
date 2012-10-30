require 'test_helper'

class QualityReportTest < MiniTest::Unit::TestCase
  include QME::DatabaseAccess
  
  def setup
    get_db()['query_cache'].drop()
    get_db()['patient_cache'].drop()
    get_db()['query_cache'].insert(
      "measure_id" => "test2",
      "sub_id" =>  "b",
      "initialPopulation" => 4,
      "numerator" => 1,
      "denominator" => 2,
      "exclusions" => 1,
      "effective_date" => Time.gm(2010, 9, 19).to_i
    )
    get_db()['patient_cache'].insert(
      "value" => {
        "population" => false,
        "denominator" => false,
        "numerator" => false,
        "exclusions" => false,
        "antinumerator" => false,
        "medical_record_id" => "0616911582",
        "first" => "Mary",
        "last" => "Edwards",
        "gender" => "F",
        "birthdate" => Time.gm(1940, 9, 19).to_i,
        "test_id" => nil,
        "provider_performances" => nil,
        "race" => {
          "code" => "2106-3",
          "code_set" => "CDC-RE"
        },
        "ethnicity" => {
          "code" => "2135-2",
          "code_set" => "CDC-RE"
        },
        "measure_id" => "test2",
        "sub_id" =>  "b",
        "effective_date" => Time.gm(2010, 9, 19).to_i 
      }
    )
  end

  def test_calculated
    qr = QME::QualityReport.new('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    assert qr.calculated?
    
    qr = QME::QualityReport.new('test2', 'b', "effective_date" => Time.gm(2010, 9, 20).to_i)
    assert !qr.calculated?
  end
  
  def test_result
    qr = QME::QualityReport.new('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    result = qr.result
    
    assert_equal 1, result['numerator']
  end
  
  def test_destroy_all
    QME::QualityReport.destroy_all
    
    qr = QME::QualityReport.new('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    assert !qr.calculated?
  end
  
  def test_update_patient_results
    qr = QME::QualityReport.new('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    assert qr.calculated?
    assert qr.patients_cached?
    QME::QualityReport.update_patient_results("0616911582")
    assert !qr.calculated?
    assert !qr.patients_cached?
  end

  def test_status
    qr = QME::QualityReport.new('test2', 'b', "effective_date" => Time.gm(2010, 9, 19).to_i)
    status = qr.status('not really a job id')
    assert_equal :complete, status
    status = qr.status("508aeff07042f9f88900000d")
    assert_equal :queued, status
  end

end