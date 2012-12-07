module QME
  module Bundle
    # Delete a list of collections. By default, this function drops all of collections related to measures and patients.
    #
    # @param [Array] collection_names Optionally, an array of collection names to be dropped.
    def self.drop_collections(db, collection_names=[])
      collection_names = ["bundles", "records", "measures", "selected_measures", "patient_cache", "query_cache", "system.js"] if collection_names.empty?
      collection_names.each {|collection| db[collection].drop}
    end

    # Save a javascript function into Mongo's system.js collection for measure execution.
    #
    # @param [String] name The name by which the function will be referred.
    # @param [String] fn The body of the function being saved.
    def self.save_system_js_fn(db, name, fn)
      fn = "function () {\n #{fn} \n }"
      db['system.js'].find('_id' => name).upsert(
        {
          "_id" => name,
          "value" => Moped::BSON::Code.new(fn)
        }
      )
    end

    # A utility function for finding files in a bundle. Strip a file path of it's extension and just give the filename.
    #
    # @param [String] original A file path.
    # @param [String] extension A file extension.
    # @return The filename at the end of the original String path with the extension removed. e.g. "/boo/urns.html" -> "urns"
    def self.entry_key(original, extension)
      original.split('/').last.gsub(".#{extension}", '')
    end
    
    def self.unpack_bundle_contents(zip, type = nil)
      bundle_contents = { bundle: nil, measures: {}, patients: {}, extensions: {}, results: {} }
      Zip::ZipFile.open(zip.path) do |zipfile|
        zipfile.entries.each do |entry|
          bundle_contents[:bundle] = zipfile.read(entry.name) if entry.name.include? "bundle"
          if type.nil? || entry.name.match(Regexp.new("/#{type}/")) 
            bundle_contents[:measures][Bundle.entry_key(entry.name, "json")] = zipfile.read(entry.name) if entry.name.match /^measures.*\.json$/
            bundle_contents[:patients][Bundle.entry_key(entry.name, "json")] = zipfile.read(entry.name) if entry.name.match /^patients.*\.json$/ # Only need to import one of the formats
            bundle_contents[:results][Bundle.entry_key(entry.name,"json")] = zipfile.read(entry.name) if entry.name.match /^results.*\.json/
          end
          bundle_contents[:extensions][Bundle.entry_key(entry.name,"js")] = zipfile.read(entry.name) if entry.name.match /^library_functions.*\.js/

        end
      end
      bundle_contents
    end
  end
end
