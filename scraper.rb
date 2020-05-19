require 'nokogiri'
require 'httparty'
require 'open-uri'

SEARCH_TERMS = [
    'entry+level+software+developer',
    'junior+software+developer',
    'junior+back+end+developer',
    'entry+level+developer',
    'junior+developer',
    'junior+full+stack+developer'
]

TARGETS = {
    'jobCard' = 'div.jobsearch-SerpJobCard',
    'numJobs' = 'div.searchCountContainer',
    'link' = 'h2.title',
    'indeed_resume' = 'div.icl-u-lg-hide',
    'apply_link' = 'div.icl-u-lg-hide',
    'title' = 'h3.icl-u-xs-mb--xs.icl-u-xs-mt--none.jobsearch-JobInfoHeader-title',
    'company_name' = 'div.jobsearch-InlineCompanyRating.icl-u-xs-mt--xs.jobsearch-DesktopStickyContainer-companyrating',
    'location' = 'div.jobsearch-InlineCompanyRating.icl-u-xs-mt--xs.jobsearch-DesktopStickyContainer-companyrating',
    'description' = 'div.jobsearch-jobDescriptionText'
}

URL_BASE = 'https://www.indeed.com/jobs?q='
URL_END = '&l=United+States&filter=0&start='

def scraper

    SEARCH_TERMS.each do |search_term|
        link = URL_BASE + search_term + URL_END
        scrape_search(link)
    end
end

def scrape_search(link)
    num_jobs = get_num_jobs(link)
    (0...num_jobs/10).times do |i|
        url = link + (i*10).to_s
        get_cards(url)
    end
end

def get_cards(link)
    page = scrape_page(link)
    jobCards = page.css('div.jobsearch-SerpJobCard')
    jobCards.each {|jobCard| scrape_card(jobCard)}
end

def get_num_jobs(link)
    page = scrape_page(link + '0')
    text = page.css('div.searchCountContainer').children[1].children[1].text
    text.delete!("\n")
    text.delete!(" ")
    nums = text.split("of").last
    (nums.split('').select {|n| n.to_i > 0}).join.to_i
end

def scrape_card(jobCard)

    job = Hash.new
    link = Hash.new 
    company = Hash.new

    link['listing_link'] = scrape_link(jobCard)
    page = scrape_page(link['listing_link'])

    job['title'] = scrape_title(page)
    job['description'] = scrape_description(page)
    job['indeed_apply'] = scrape_indeed_resume?(page)

    if job['indeed_apply']
        link['apply_link'] = link['listing_link']
    else  
        link['apply_link'] = scrape_apply_link(page)
    end

    company['name'] = scrape_company_name(page)
    company['loc'] = scrape_location(page)

    
end

def scrape_link(jobCard)
    h2 = jobCard.css('h2.title').children[1]
    catch_redirect("https://www.indeed.com" + h2['href']) 
end

def scrape_indeed_resume?(page)
    container = page.css('div.icl-u-lg-hide').children[1]
    container.name == "button"
end

def scrape_apply_link(page)
    container = page.css('div.icl-u-lg-hide').children[1]
    container['href']
end

def scrape_title(page)
    page.css('h3.icl-u-xs-mb--xs.icl-u-xs-mt--none.jobsearch-JobInfoHeader-title').text
end

def scrape_company_name(page)
    page.css('div.jobsearch-InlineCompanyRating.icl-u-xs-mt--xs.jobsearch-DesktopStickyContainer-companyrating').children.first.text
end

def scrape_location(page)
    info = page.css('div.jobsearch-InlineCompanyRating.icl-u-xs-mt--xs.jobsearch-DesktopStickyContainer-companyrating')
    info.children.each_with_index do |child, idx|
        if child.text == '-'
            return info.children[idx+1].text
        end
    end
    nil
end

def scrape_description(page)
    out = []
    info = page.css('div.jobsearch-jobDescriptionText')
    info.children.each do |el|
        out << el.text
    end
    out.join("\n")
end

def catch_redirect(link)
    resp = open(link)
    dest = resp.base_uri.to_s
    return dest if dest == link 
    catch_redirect(dest)
end

def scrape_page(link)
    Nokogiri::HTML(HTTParty.get(link))
end

scraper