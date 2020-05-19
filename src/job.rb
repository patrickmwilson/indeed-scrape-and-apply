require 'sqlite3'
require_relative 'db_connection'

class Job
    attr_accessor :id, :title, :company_id, :summary, :indeed_apply, :applied

    def self.all 
        data = DBConnection.instance.execute("SELECT * FROM jobs")
        data.map {|datum| Job.new(datum)}
    end

    def self.find_by_id(id)
        job = DBConnection.instance.execute(<<-SQL, id)
            SELECT 
                *
            FROM
                jobs
            WHERE
                id = ?
        SQL
        return nil unless job.length > 0
        Job.new(job.first)
    end

    def self.find_by_title(title, num)
        jobs = DBConnection.instance.execute(<<-SQL, title, num)
            SELECT
                *
            FROM
                jobs
            WHERE
                title = ?
            LIMIT(?)
        SQL
        return nil unless jobs.length > 0
        jobs.map{|job| Job.new(job)}
    end

    def self.find_by_company(company_id)
        jobs = DBConnection.instance.execute(<<-SQL, company_id)
            SELECT
                *
            FROM
                jobs
            WHERE
                company_id = ?
        SQL
        return nil unless jobs.length > 0
        jobs.map{|job| Job.new(job)}
    end

    def self.find_applied(state = true, num)
        jobs = DBConnection.instance.execute(<<-SQL, state, num)
            SELECT
                *
            FROM
                jobs
            WHERE
                applied = ?
            LIMIT(?)
        SQL
        return nil unless jobs.length > 0
        jobs.map{|job| Job.new(job)}
    end

    def self.find_by_apply_method(indeed = true, num)
        jobs = DBConnection.instance.execute(<<-SQL, indeed, num)
            SELECT
                *
            FROM
                jobs
            WHERE
                indeed_apply = ?
            LIMIT(?)
        SQL
        return nil unless jobs.length > 0
        jobs.map{|job| Job.new(job)}
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @company_id = options['company_id']
        @summary = options['summary']
        @indeed_apply = options['indeed_apply']
        @applied = options['applied'] || false
    end

    def insert 
        raise "#{self} already in database" if self.id
        DBConnection.instance.execute(<<-SQL, self.title, self.company_id, self.summary, self.indeed_resume, self.applied)
            INSERT INTO
                jobs(title, company_id, summary, indeed_resume, applied)
            VALUES
                (?, ?, ?, ?, ?)
        SQL
    end

    def update
        raise "#{self} not in database" unless self.id
        DBConnection.instance.execute(<<-SQL, self.title, self.company_id, self.summary, self.indeed_resume, self.applied, self.id)
            UPDATE
                jobs
            SET
                title = ?, company = ?, loc = ?, summary = ?, link = ?, apply_link = ?, indeed_resume = ?, applied = ?)
            WHERE
                id = ?
        SQL
    end

    def company 
        Company.find_by_id(self.company_id)
    end

    def link 
        Link.find_by_job_id(self.id)
    end

end