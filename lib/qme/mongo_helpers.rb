module QME
  module MongoHelpers
    # Evaluates underscore.js in the "js" directory of this project on
    # the Mongo database passed in. This will make the library available
    # to subsiquent calls on the database. This is useful for queries with 
    # where clauses or MapReduce functions
    #
    # @param [Mongo::DB] db The database to evaluate the JavaScript on
    def self.initialize_javascript_frameworks(db,bundle_collection = 'bundles')
      underscore_js = File.read(File.join(File.dirname(__FILE__), '..', '..', 'js', 'underscore-min.js'))
      db.eval(underscore_js)
    end
    
  end
end