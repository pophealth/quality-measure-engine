module QME
  module Bundle
    class Importer
      include QME::DatabaseAccess

      # Create a new Importer.
      # @param [String] db_name the name of the database to use
      def initialize(db_name = nil)
        determine_connection_information(db_name)
        @db = get_db
      end

      # Import a quality bundle into the database. This includes metadata, measures, test patients, supporting JS libraries, and expected results.
      #
      # @param [File] zip The bundle zip file.
      # @param [String] Type of measures to import, either 'ep', 'eh' or nil for all
      # @param [Boolean] keep_existing If true, delete all current collections related to patients and measures.
      def import(zip, type, delete_existing)
        Bundle.drop_collections(@db) if delete_existing
        
        # Unpack content from the bundle.
        bundle_contents = QME::Bundle.unpack_bundle_contents(zip, type)

        # Store all JS libraries.
        bundle_contents[:extensions].each do |key, contents|
          Bundle.save_system_js_fn(@db, key, contents)
        end

        # Store the bundle metadata.
        bundle_id = Moped::BSON::ObjectId.new()
        bundle = JSON.parse(bundle_contents[:bundle])
        bundle["_id"] = bundle_id
        @db['bundles'].insert(bundle)
        
        # Store all measures.
        bundle_contents[:measures].each do |key, contents|
          measure_id = Moped::BSON::ObjectId.new()
          measure = JSON.parse(contents, {:max_nesting => 100})
          measure['_id'] = measure_id
          measure['bundle'] = bundle_id  
          @db['measures'].insert(measure)
        end
        
        # Store all patients.
        bundle_id = Moped::BSON::ObjectId(bundle_id.to_s)
        bundle_contents[:patients].each do |key, contents|
          patient = JSON.parse(contents, {:max_nesting => 100})
          patient['bundle'] = bundle_id
          Record.new(patient).save
        end
        
        # Store the expected results into the query and patient caches.
        bundle_contents[:results].each do |name, contents|
          collection = name == "by_patient" ? "patient_cache" : "query_cache"
          contents = JSON.parse(contents, {:max_nesting => 100})
          contents.each {|document| @db[collection].insert(document)}
        end
        
        bundle_contents
      end
    end
  end
end