require 'pg'
require_relative 'db_connection'

class Job
    attr_accessor :id, :title, :company_id, :location, :description, :indeed_resume, :applied

    def self.all 
        data = DBConnection.instance.execute("SELECT * FROM jobs")
        data.map {|datum| Job.new(datum)}
    end

    def self.count_num
        DBConnection.instance.execute("SELECT COUNT(*) FROM jobs")
    end

    def self.find_by_id(id)
        job = DBConnection.instance.execute(<<-SQL)
            SELECT 
                *
            FROM
                jobs
            WHERE
                id = id
        SQL
        return nil unless job.ntuples > 0
        Job.new(job.first)
    end

    def self.find_by_title(title, num = 1)
        jobs = DBConnection.instance.execute(<<-SQL)
            SELECT
                *
            FROM
                jobs
            WHERE
                title = title
            LIMIT(num)
        SQL
        return nil unless jobs.ntuples > 0
        jobs.map{|job| Job.new(job)}
    end

    def self.find_by_company(company_id)
        jobs = DBConnection.instance.execute(<<-SQL)
            SELECT
                *
            FROM
                jobs
            WHERE
                company_id = company_id
        SQL
        return nil unless jobs.ntuples > 0
        jobs.map{|job| Job.new(job)}
    end

    def self.find_by_company_and_title(company_id, title)
        jobs = DBConnection.instance.execute(<<-SQL)
            SELECT
                *
            FROM
                jobs
            WHERE
                company_id = company_id AND title = title
        SQL
        return nil unless jobs.ntuples > 0
        Job.new(jobs.first)
    end

    def self.find_applied(state = 1, num = 1)
        jobs = DBConnection.instance.execute(<<-SQL)
            SELECT
                *
            FROM
                jobs
            WHERE
                applied = state
            LIMIT(num)
        SQL
        return nil unless jobs.ntuples > 0
        jobs.map{|job| Job.new(job)}
    end

    def self.find_by_apply_method(indeed_resume = 1, num = 1)
        jobs = DBConnection.instance.execute(<<-SQL)
            SELECT
                *
            FROM
                jobs
            WHERE
                indeed_resume = indeed_resume
            LIMIT(num)
        SQL
        return nil unless jobs.ntuples > 0
        jobs.map{|job| Job.new(job)}
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @company_id = options['company_id']
        @location = options['location']
        @description = options['description']
        @indeed_resume = options['indeed_resume']
        @applied = options['applied'] || 0
    end

    def save
        raise "#{self} already in database" if self.id
        DBConnection.instance.execute(<<-SQL)
            INSERT INTO
                jobs(title, company_id, location, description, indeed_resume, applied)
            VALUES
                (self.title, self.company_id, self.location, self.description, self.indeed_resume, self.applied)
        SQL
    end

    def update
        raise "#{self} not in database" unless self.id
        DBConnection.instance.execute(<<-SQL)
            UPDATE
                jobs
            SET
                title = self.title, company_id = self.company_id, location = self.location, description = self.description, indeed_resume = self.indeed_resume, applied = self.applied
            WHERE
                id = self.id
        SQL
    end

    def delete 
        raise "#{self} not in database" unless self.id 
        link = Link.find_by_job_id(self.id)
        link.delete if link
        DBConnection.instance.execute(<<-SQL)
            DELETE FROM
                jobs
            WHERE
                id = self.id
        SQL
    end

    def company 
        Company.find_by_id(self.company_id)
    end

    def link 
        Link.find_by_job_id(self.id)
    end
end