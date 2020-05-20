require 'nokogiri'
require 'httparty'
require 'open-uri'
require 'open_uri_redirections'
require_relative 'parser'

TARGETS = {
    'jobCard' => 'div.jobsearch-SerpJobCard',
    'num_jobs' => 'div.searchCountContainer',
    'link' => 'h2.title',
    'indeed_resume' => 'div.icl-u-lg-hide',
    'apply_link' => 'div.icl-u-lg-hide',
    'title' => 'h3.icl-u-xs-mb--xs.icl-u-xs-mt--none.jobsearch-JobInfoHeader-title',
    'company_name' => 'div.jobsearch-InlineCompanyRating.icl-u-xs-mt--xs.jobsearch-DesktopStickyContainer-companyrating',
    'location' => 'div.jobsearch-InlineCompanyRating.icl-u-xs-mt--xs.jobsearch-DesktopStickyContainer-companyrating',
    'description' => 'div.jobsearch-jobDescriptionText'
}

URL_BASE = 'https://www.indeed.com/jobs?q='
URL_END = '&l=United+States&filter=0&start='

class Scraper

    def initialize(search_term)
        @search_term = search_term
    end

    def run
        link = URL_BASE + @search_term + URL_END
        scrape_search(link)
    end

    private 

    def scrape_search(link)
        num_jobs = get_num_jobs(link)
        (0...num_jobs/10).each do |i|
            url = link + (i*10).to_s
            jobCards = get_cards(url)
            jobCards.each {|jobCard| scrape_card(jobCard)}
        end
    end

    def get_num_jobs(link)
        page = scrape_page(link + '0')
        text = page.css(TARGETS['num_jobs']).children[1].children[1].text
        text.delete!("\n")
        text.delete!(" ")
        nums = text.split("of").last
        (nums.split('').select {|n| n.to_i > 0}).join.to_i
    end

    def get_cards(link)
        page = scrape_page(link)
        page.css(TARGETS['jobCard'])
    end

    def scrape_card(jobCard)
        job = Hash.new
        link = Hash.new 
        company = Hash.new

        link['listing_link'] = scrape_link(jobCard)
        page = scrape_page(link['listing_link'])

        job['title'] = scrape_title(page)
        job['description'] = scrape_description(page)
        job['indeed_resume'] = scrape_indeed_resume?(page)
        job['location'] = scrape_location(page)

        if job['indeed_resume'] == 1
            link['apply_link'] = link['listing_link']
        else  
            link['apply_link'] = scrape_apply_link(page)
        end

        company['name'] = scrape_company_name(page)
        Parser.instance.execute(job, company, link)
    end

    def scrape_link(jobCard)
        h2 = jobCard.css(TARGETS['link']).children[1]
        catch_redirect("https://www.indeed.com" + h2['href']) 
    end

    def scrape_apply_link(page)
        container = page.css(TARGETS['apply_link']).children[1]
        container['href']
    end

    def scrape_indeed_resume?(page)
        container = page.css('div.icl-u-lg-hide').children[1]
        container.name == "button" ? 1 : 0
    end

    def scrape_title(page)
        page.css(TARGETS['title']).text
    end

    def scrape_company_name(page)
        page.css(TARGETS['company_name']).children.first.text
    end

    def scrape_location(page)
        info = page.css(TARGETS['location'])
        info.children.each_with_index do |child, idx|
            return info.children[idx+1].text if child.text == '-'
        end
        nil
    end

    def scrape_description(page)
        out = []
        info = page.css(TARGETS['description'])
        info.children.each do |child|
            out << child.text
        end
        out.join("\n")
    end

    def catch_redirect(link)
        resp = open(link, :allow_redirections => :all)
        dest = resp.base_uri.to_s
        return dest if dest == link 
        catch_redirect(dest)
    end

    def scrape_page(link)
        Nokogiri::HTML(HTTParty.get(link))
    end
end