require 'sqlite3'
require_relative 'db_connection'
require_relative 'job'

class Company

    attr_accessor :id, :name, :loc

    def self.find_by_id(id)
        company = DBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                companies
            WHERE
                id = ?
        SQL
        return nil unless company.length > 0
        Company.new(company.first)
    end

    def self.find_by_name(name)
        company = DBConnection.instance.execute(<<-SQL, name)
            SELECT
                *
            FROM
                companies
            WHERE
                name = ?
        SQL
        return nil unless company.length > 0
        Company.new(company.first)
    end

    def initialize(options)
        @id = options['id']
        @name = options['name']
        @loc = options['loc']
    end

    def insert 
        raise "#{self} already in database" if self.id 
        DBConnection.instance.execute(<<-SQL, self.name, self.loc)
            INSERT INTO
                companies(name, loc)
            VALUES
                (?, ?)
        SQL
    end

    def update
        raise "#{self} not in database" unless self.id 
        DBConnection.instance.execute(<<-SQL, self.name, self.loc, self.id)
            UPDATE
                companies
            SET
                name = ?, loc = ?
            WHERE
                id = ?
        SQL
    end

    def jobs
        Job.find_by_company(self.id)
    end
end