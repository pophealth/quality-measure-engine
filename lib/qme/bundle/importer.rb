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
        drop_collections if delete_existing
        
        # Unpack content from the bundle.
        bundle_contents = { bundle: nil, measures: {}, patients: {}, libraries: {}, results: {} }
        Zip::ZipFile.open(zip.path) do |zipfile|
          zipfile.entries.each do |entry|
            bundle_contents[:bundle] = zipfile.read(entry.name) if entry.name.match /^bundle/
            bundle_contents[:measures][entry_key(entry.name, "json")] = zipfile.read(entry.name) if entry.name.match /^measures/
            bundle_contents[:patients][entry_key(entry.name, "json")] = zipfile.read(entry.name) if entry.name.match /^patients.*\.json$/ # Only need to import one of the formats
            bundle_contents[:libraries][entry_key(entry.name,"js")] = zipfile.read(entry.name) if entry.name.match /^libraries/
            bundle_contents[:results][entry_key(entry.name,"json")] = zipfile.read(entry.name) if entry.name.match /^results/
          end
        end

        # Store all JS libraries.
        bundle_contents[:libraries].each do |key,contents|
          save_system_js_fn(key, contents)
        end

        # Store the bundle metadata.
        bundle = JSON.parse(bundle_contents[:bundle])
        bundle_id = @db['bundles'] << bundle
        
        # Store all measures.
        bundle_contents[:measures].each do |key, contents|
          measure = JSON.parse(contents, {:max_nesting => 100})
          measure['bundle'] = bundle_id  
          @db['measures'] << measure
        end
        
        # Store all patients.
        bundle_contents[:patients].each do |key, contents|
          patient = JSON.parse(contents, {:max_nesting => 100})
          patient['bundle'] = bundle_id
          @db['records'] << patient
        end
        
        # Store the expected results into the query and patient caches.
        bundle_contents[:results].each do |name, contents|
          collection = name == "by_patient" ? "patient_cache" : "query_cache"
          contents = JSON.parse(contents, {:max_nesting => 100})
          contents.each {|document| @db[collection] << document}
        end
      end

      # Delete a list of collections. By default, this function drops all of collections related to measures and patients.
      #
      # @param [Array] collection_names Optionally, an array of collection names to be dropped.
      def drop_collections(collection_names=[])
        collection_names = ["bundles", "records", "measures", "selected_measures", "patient_cache", "query_cache"] if collection_names.empty?
        collection_names.each {|collection| @db[collection].drop}
      end

      # Save a javascript function into Mongo's system.js collection for measure execution.
      #
      # @param [String] name The name by which the function will be referred.
      # @param [String] fn The body of the function being saved.
      def save_system_js_fn(name, fn)
        fn = "function () {\n #{fn} \n }"
        @db['system.js'].save(
          {
            "_id" => name,
            "value" => BSON::Code.new(fn)
          }
        )
      end

      private

      # A utility function for importing from a bundle. Strip a file path of it's extension and just give the filename.
      #
      # @param [String] original A file path.
      # @param [String] extension A file extension.
      # @return The filename at the end of the original String path with the extension removed. e.g. "/boo/urns.html" -> "urns"
      def entry_key(original, extension)
        original.split('/').last.gsub(".#{extension}", '')
      end

    end
  end
end