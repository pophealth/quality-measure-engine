module QME
  module DatabaseAccess 
    # Lazily creates a connection to the database and initializes the
    # JavaScript environment
    # @return [Moped::Session]
    def get_db
      Mongoid.default_session
    end
  end
end