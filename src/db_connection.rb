require 'sqlite3'
require 'singleton'

class DBConnection < SQLite3::Database
    include 'singleton'

    def initialize 
        super('jobs.db')
        self.type_translations = true 
        self.results_as_hash = true
    end
end
