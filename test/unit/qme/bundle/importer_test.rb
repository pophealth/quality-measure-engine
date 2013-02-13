require 'test_helper'
require 'pry-nav'

class ImporterTest< MiniTest::Unit::TestCase
  include QME::DatabaseAccess

  def setup
  	@zip1 = File.join("test","fixtures","bundles","just_measure_0002.zip")
  	@zip2 = File.join("test","fixtures","bundles","measures_0003_0002.zip")
  	["records","measures","bundles","patient_cache","query_cache"].each do |collection|
  		get_db[collection].drop
  	end
  end

  def assert_clean_db
  	["records","measures","bundles","patient_cache","query_cache"].each do |collection|
  		assert_equal get_db[collection].where({}).count , 0, "Should be 0 #{collection} in the db"
  	end
  	
  end

  def test_load
  	assert_clean_db
  	loader = QME::Bundle::Importer.new(get_db.options["database"])

  	loader.import(File.new(@zip1), false)
  	assert_equal get_db["bundles"].where({}).count , 1, "Should be 1 bundle in the db"
  	assert_equal get_db["measures"].where({}).count , 1, "Should be 1 measure in the db"
  	assert_equal get_db["records"].where({}).count , 0, "Should be 0 records in the db"
  	assert_equal get_db["patient_cache"].where({}).count , 0, "Should be 0 entries in the patient_cache "
  	assert_equal get_db["query_cache"].where({}).count , 0, "Should be 0 entries in the query_cache "

  	bundle_id = get_db["bundles"].where({}).first["_id"]
  	measure = get_db["measures"].where({}).first
  	assert_equal [bundle_id], measure["bundle_ids"] 


  	loader.import(File.new(@zip2),false)
  	assert_equal get_db["bundles"].where({}).count , 2, "Should be 1 bundle in the db"
  	assert_equal get_db["measures"].where({}).count , 2, "Should be 1 measure in the db"
  	assert_equal get_db["records"].where({}).count , 0, "Should be 0 records in the db"
  	assert get_db["patient_cache"].where({}).count > 0, "Should be more than  0 entries in the patient_cache "
  	assert get_db["query_cache"].where({}).count > 0, "Should be 0 more than  entries in the query_cache "

  	bundle_id1 = get_db["bundles"].where({}).first["_id"]
  	bundle_id2 = get_db["bundles"].where({}).to_a[1]["_id"]
  	measure_0002 = get_db["measures"].where({"nqf_id" => "0002"}).first
  	measure_0003 = get_db["measures"].where({"nqf_id" => "0003"}).first
  	assert_equal [bundle_id1, bundle_id2], measure_0002["bundle_ids"] ,  "Should have both bundle ids on it"
  	assert_equal [bundle_id2], measure_0003["bundle_ids"] ,  "should only have the last bundle id on it"

  	["records", "patient_cache", "query_cache"].each do |collection|
  		get_db[collection].where({}).each do |record|
  			assert_equal bundle_id2, record["bundle_id"], "Expected Entry #{record["_id"]} of colelction #{collection} to have a bundle_id of #{bundle_id2}"
  		end
  	end

  	loader.import(File.new(@zip1), true)
  	assert_equal get_db["bundles"].where({}).count , 1, "Should be 1 bundle in the db"
  	assert_equal get_db["measures"].where({}).count , 1, "Should be 1 measure in the db"
  	assert_equal get_db["records"].where({}).count , 0, "Should be 0 records in the db"
  	assert_equal get_db["patient_cache"].where({}).count , 0, "Should be 0 entries in the patient_cache "
  	assert_equal get_db["query_cache"].where({}).count , 0, "Should be 0 entries in the query_cache "

  	bundle_id = get_db["bundles"].where({}).first["_id"]
  	measure = get_db["measures"].where({}).first
  	assert_equal measure["bundle_ids"] , [bundle_id]



  	
    
  end




end