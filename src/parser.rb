require_relative 'job'
require_relative 'company'
require_relative 'link'
require 'singleton'

class Parser
    include Singleton

    def initialize
    end

    def execute(job_options, company_options, link_options)
        job_options['company_id'] = parse_company(company_options)
        link_options['job_id'] = parse_job(job_options)
        parse_link(link_options)
        puts '-'*25
        puts Company.count_num
        puts Job.count_num
    end

    private 

    def parse_company(company_options) 
        company = Company.find_by_name(company_options['name'])
        return company.id if company && company.id
        Company.new(company_options).save 
        parse_company(company_options)
    end

    def parse_job(job_options)
        job = Job.find_by_company_and_title(job_options['company_id'], job_options['title'])
        return job.id if job && job.id
        Job.new(job_options).save
        parse_job(job_options)
    end

    def parse_link(link_options)
        link = Link.find_by_job_id(link_options['job_id'])
        return if link && link.id
        Link.new(link_options).save 
        parse_link(link_options)
    end
end