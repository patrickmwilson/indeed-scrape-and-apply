require 'sqlite3'
require_relative 'db_connection'

class Link

    def self.find_by_job_id(job_id)
        link = DBConnection.instance.execute(<<-SQL, job_id)
            SELECT
                *
            FROM
                links
            WHERE
                job_id = ?
        SQL
        return nil unless link.length > 0
        Link.new(link.first)
    end

    def initialize(options)
        @listing_link = options['listing_link']
        @apply_link = options['apply_link']
        @job_id = options['job_id']
    end

    def insert 
        raise "#{self} already in database" if self.id 
        DBConnection.instance.execute(<<-SQL, self.listing_link, self.apply_link, self.job_id)
            INSERT INTO
                links(listing_link, apply_link, job_id)
            VALUES
                (?, ?, ?)
        SQL
    end

    def update
        raise "#{self} not in database" unless self.id 
        DBConnection.instance.execute(<<-SQL, self.listing_link, self.apply_link, self.job_id, self.id)
            UPDATE
                links
            SET
                listing_link = ?, apply_link = ?, job_id = ?
            WHERE
                id = ?
        SQL
    end
end