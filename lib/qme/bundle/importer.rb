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
      # @param [Boolean] keep_existing If true, delete all current collections related to patients and measures.
      def import(zip, delete_existing)
        Bundle.drop_collections(@db) if delete_existing
        
        # Unpack content from the bundle.
        bundle_contents = { bundle: nil, measures: {}, patients: {}, extensions: {}, results: {} }
        Zip::ZipFile.open(zip.path) do |zipfile|
          zipfile.entries.each do |entry|
            bundle_contents[:bundle] = zipfile.read(entry.name) if entry.name.match /^bundle/
            bundle_contents[:measures][Bundle.entry_key(entry.name, "json")] = zipfile.read(entry.name) if entry.name.match /^measures/
            bundle_contents[:patients][Bundle.entry_key(entry.name, "json")] = zipfile.read(entry.name) if entry.name.match /^patients.*\.json$/ # Only need to import one of the formats
            bundle_contents[:extensions][Bundle.entry_key(entry.name,"js")] = zipfile.read(entry.name) if entry.name.match /^library_functions/
            bundle_contents[:results][Bundle.entry_key(entry.name,"json")] = zipfile.read(entry.name) if entry.name.match /^results/
          end
        end

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
      end
    end
  end
end