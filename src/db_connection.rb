require 'pg'
require 'singleton'

class DBConnection 
    include Singleton

    def initialize 
        @conn = PG::Connection.open(:dbname => 'jobs')
    end

    def execute(sql)
        @conn.exec(sql)
    end
end
