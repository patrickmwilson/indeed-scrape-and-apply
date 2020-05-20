require 'pg'
require_relative 'db_connection'
require_relative 'job'

class Company

    attr_accessor :id, :name

    def self.all 
        data = DBConnection.instance.execute("SELECT * FROM companies")
        data.map {|datum| Company.new(datum)}
    end

    def self.count_num
        DBConnection.instance.execute("SELECT COUNT(*) FROM companies")
    end

    def self.find_by_id(id)
        company = DBConnection.instance.execute(<<-SQL)
            SELECT
                *
            FROM
                companies
            WHERE
                id = id
        SQL
        return nil unless company.ntuples > 0
        Company.new(company.first)
    end

    def self.find_by_name(name)
        company = DBConnection.instance.execute(<<-SQL)
            SELECT
                *
            FROM
                companies
            WHERE
                name = name
        SQL
        return nil unless company.ntuples > 0
        Company.new(company.first)
    end

    def initialize(options)
        @id = options['id']
        @name = options['name']
    end

    def save
        raise "#{self} already in database" if self.id 
        DBConnection.instance.execute(<<-SQL)
            INSERT INTO
                companies(name)
            VALUES
                (self.name)
        SQL
    end

    def update
        raise "#{self} not in database" unless self.id 
        DBConnection.instance.execute(<<-SQL)
            UPDATE
                companies
            SET
                name = self.name
            WHERE
                id = self.id
        SQL
    end

    def delete 
        raise "#{self} not in database" unless self.id 
        Job.find_by_company(self.id).each {|job| job.delete}
        DBConnection.instance.execute(<<-SQL)
            DELETE FROM
                companies
            WHERE
                id = self.id
        SQL
    end

    def jobs
        Job.find_by_company(self.id)
    end
end