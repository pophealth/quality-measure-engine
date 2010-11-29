module QME
  module MongoHelpers
    # Evaluates any JavaScript files in the "js" directory of this project on
    # the Mongo database passed in. This will make any functions or variables
    # defined in the JavaScript files available to subsiquent calls on the
    # database. This is useful for queries with where clauses or MapReduce
    # functions
    #
    # @param [Mongo::DB] db The database to evaluate the JavaScript on
    def self.initialize_javascript_frameworks(db)
      Dir.glob(File.join(File.dirname(__FILE__), '..', '..', 'js', '*.js')).each do |js_file|
        raw_js = File.read(js_file)
        db.eval(raw_js)
      end
    end
  end
end