require 'simplecov_setup'
require 'minitest/autorun'
require 'quality-measure-engine'

Mongo::Logger.logger.level = Logger::WARN
Mongoid.load!(File.join(File.dirname(__FILE__),"mongoid.yml"), :test)

class MiniTest::Unit::TestCase

  def load_system_js
    Mongoid.default_client['system.js'].delete_many({})
    Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', "library_functions", '*.js')).each do |json_fixture_file|
      name = File.basename(json_fixture_file,".*")
      fn = "function () {\n #{File.read(json_fixture_file)} \n }"
      Mongoid.default_client['system.js'].update_one({
          "_id" => name},
        {
          "_id" => name,
          "value" => BSON::Code.new(fn)
        },{upsert: true}
      )
    end

  end


  def value_or_bson(v)
    if v.is_a? Hash
      if v['$oid']
        BSON::ObjectId.from_string(v['$oid'])
      else
        map_bson_ids(v)
      end
    else
      v
    end
  end

  def map_array(arr)
    ret = []
    arr.each do |v|
      ret << value_or_bson(v)
    end
    ret
  end

  def map_bson_ids(json)
    json.each_pair do |k, v|
      if v.is_a? Hash
        json[k] = value_or_bson(v)
      elsif v.is_a? Array
        json[k] = map_array(v)
      elsif k == 'create_at' || k == 'updated_at'
        json[k] = Time.at.local(v).in_time_zone
      end
    end
    json
  end

  def collection_fixtures(*collections)
    collections.each do |collection|
      get_db()[collection].drop
      Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', collection, '*.json')).each do |json_fixture_file|
        fixture_json = JSON.parse(File.read(json_fixture_file), max_nesting: 250)
        fixture_json['_id'] = BSON::ObjectId.from_string(fixture_json['_id']) if fixture_json['_id']
        map_bson_ids(fixture_json)
        Mongoid.default_client[collection].insert_one(fixture_json)
      end
    end
  end
end
