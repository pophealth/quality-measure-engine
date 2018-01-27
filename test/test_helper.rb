require 'simplecov_setup'
require 'minitest/autorun'
require 'quality-measure-engine'
require 'pry-nav'

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

  # Add more helper methods to be used by all tests here...

  def collection_fixtures(db, collection, *id_attributes)
    db[collection].drop
    Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', collection, '*.json')).each do |json_fixture_file|
      #puts "Loading #{json_fixture_file}"
      fixture_json = JSON.parse(File.read(json_fixture_file))
      id_attributes.each do |attr|
        fixture_json[attr] = BSON::ObjectId.from_string(fixture_json[attr])
      end
      db[collection].insert_one(fixture_json)
    end
  end
end
