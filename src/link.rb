require 'pg'
require_relative 'db_connection'

class Link

    attr_accessor :id, :listing_link, :apply_link, :job_id

    def self.all 
        data = DBConnection.instance.execute("SELECT * FROM links")
        data.map {|datum| Link.new(datum)}
    end

    def self.find_by_job_id(job_id)
        link = DBConnection.instance.execute(<<-SQL)
            SELECT
                *
            FROM
                links
            WHERE
                job_id = job_id
        SQL
        return nil unless link.ntuples > 0
        Link.new(link.first)
    end

    def initialize(options)
        @id = options['id']
        @listing_link = options['listing_link']
        @apply_link = options['apply_link']
        @job_id = options['job_id']

        self.save unless @id
    end

    def save
        raise "#{self} already in database" if self.id 
        DBConnection.instance.execute(<<-SQL)
            INSERT INTO
                links(listing_link, apply_link, job_id)
            VALUES
                (self.listing_link, self.apply_link, self.job_id)
        SQL
    end

    def update
        raise "#{self} not in database" unless self.id 
        DBConnection.instance.execute(<<-SQL)
            UPDATE
                links
            SET
                listing_link = self.listing_link, apply_link = self.apply_link, job_id = self.job_id
            WHERE
                id = self.id
        SQL
    end

    def delete 
        raise "#{self} not in database" unless self.id 
        DBConnection.instance.execute(<<-SQL)
            DELETE FROM
                links
            WHERE
                id = self.id
        SQL
    end

    
end