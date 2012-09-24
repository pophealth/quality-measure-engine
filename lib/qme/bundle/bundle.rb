module QME
  module Bundle
    # Delete a list of collections. By default, this function drops all of collections related to measures and patients.
    #
    # @param [Array] collection_names Optionally, an array of collection names to be dropped.
    def self.drop_collections(db, collection_names=[])
      collection_names = ["bundles", "records", "measures", "selected_measures", "patient_cache", "query_cache", "System.js"] if collection_names.empty?
      collection_names.each {|collection| db[collection].drop}
    end

    # Save a javascript function into Mongo's system.js collection for measure execution.
    #
    # @param [String] name The name by which the function will be referred.
    # @param [String] fn The body of the function being saved.
    def self.save_system_js_fn(db, name, fn)
      fn = "function () {\n #{fn} \n }"
      db['system.js'].save(
        {
          "_id" => name,
          "value" => BSON::Code.new(fn)
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
  end
end
