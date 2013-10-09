require 'simplecov_setup'
require 'minitest/autorun'
require 'quality-measure-engine'
require 'test/unit'
require 'turn'
require 'pry-nav'
Mongoid.load!(File.join(File.dirname(__FILE__),"mongoid.yml"), :test)

class MiniTest::Unit::TestCase

  def load_system_js
    Mongoid.default_session['system.js'].find.remove_all
    Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', "library_functions", '*.js')).each do |json_fixture_file|
      name = File.basename(json_fixture_file,".*")
      fn = "function () {\n #{File.read(json_fixture_file)} \n }"
      Mongoid.default_session['system.js'].find('_id' => name).upsert(
        {
          "_id" => name,
          "value" => Moped::BSON::Code.new(fn)
        }
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
        fixture_json[attr] = Moped::BSON::ObjectId.from_string(fixture_json[attr])
      end

      db[collection].insert(fixture_json)
    end
  end
end