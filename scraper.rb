require 'nokogiri'
require 'httparty'
require 'open-uri'

def scraper
    url = 'https://www.indeed.com/jobs?q=entry+level+software+developer&l=United+States&start=0'

    page = scrape_page(url)

    jobCards = page.css('div.jobsearch-SerpJobCard')

    jobCards.each {|jobCard| scrape_card(jobCard)}
end

def scrape_card(jobCard)

    title = get_title(jobCard)
    link = get_link(jobCard)
    name, rating = company_info(jobCard) 
    location = get_location(jobCard)
    summary = get_summary(jobCard)
    puts "-"*25
    puts ''
    puts title 
    puts ''
    puts link 
    puts ''
    puts name
    puts rating 
    puts location
    puts ''
    puts summary
end

def get_title(jobCard)
    h2 = jobCard.css('h2.title').children[1]
    h2['title']
end

def get_link(jobCard)
    h2 = jobCard.css('h2.title').children[1]
    catch_redirect("https://www.indeed.com" + h2['href']) 
end

def get_location(jobCard)
    (jobCard.css('div.location').text).delete!("\n")
end

def get_summary(jobCard)
    (jobCard.css('div.summary').text).delete!("\n") 
end

def company_info(jobCard)
    co = jobCard.css('span.company').children[1] 
    return [nil,nil] if co.nil?
    return [jobCard.css('span.company').text.delete!("\n"), nil] if co['href'].nil?
    company_link = catch_redirect("https://www.indeed.com" + co['href'])

    page = scrape_page(company_link)
    name = jobCard.css('span.company').text.delete!("\n")
    #name = page.css('span.cmp-CompactHeaderCompanyName').text
    rating = page.css('cmp-CompactHeaderCompanyRatings-value').text

    [name, rating]
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