module QME
  module MongoHelpers
    # Evaluates any JavaScript files in the "js" directory of this project on
    # the Mongo database passed in. This will make any functions or variables
    # defined in the JavaScript files available to subsiquent calls on the
    # database. This is useful for queries with where clauses or MapReduce
    # functions
    #
    # @param [Mongo::DB] db The database to evaluate the JavaScript on
    def self.initialize_javascript_frameworks(db,bundle_collection = 'bundles')
#       Dir.glob(File.join(File.dirname(__FILE__), '..', '..', 'js', '*.js')).each do |js_file|
#         raw_js = File.read(js_file)
#         db.eval(raw_js)
#       end
    end
    
    # See documentation for initialize_javascript_frameworks
    # This methods adds ability to call and initialize additional js files 
    # containined in a directory
    # @param [Mongo::DB]  the db to initialize the javascript on
    # @param [String] directory the directory to search for javascript files in 
    def self.initialize_additional_frameworks(db, directory)
#       Dir.glob(File.join(directory, '*.js')).each do |js_file|
#              raw_js = File.read(js_file)
#              db.eval(raw_js)
#       end
    end
    
    # See documentation for initialize_javascript_frameworks
    # This method loads Javascript that has been stored with bundles in the database
    # @param [Mongo::DB]  the db to initialize the javascript on
    # @param [String] collection the name of the bundle collection, defaults to bundles
    def self.initialze_stored_bundle_frameworks(db, collection = "bundles")
#       db[collection].find.each do |bundle|
#          (bundle['extensions'] || []).each do |ext|
#            db.eval(ext)
#          end
#       end
    end
  end
end