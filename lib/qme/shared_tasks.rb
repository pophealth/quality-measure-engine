module QME
  class SharedTasks
    # Requires rake tasks from a list of rake files located in the tasks directory.
    #
    # @param [Array] rake_files A list of rake files to be loaded. Defaults to importing everything.
    def self.import(rake_files = ["**/*"])
      puts File.join(File.dirname(__FILE__), "..", "tasks")
      rake_files.each do |rake_file|
        Dir[File.join(File.dirname(__FILE__), "..", "tasks", "#{rake_file}.rake")].sort.each do |ext|
          load ext
        end
      end
    end
  end
end