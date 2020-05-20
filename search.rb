require_relative 'src/scraper.rb'

SEARCH_TERMS = [
    'entry+level+software+developer',
    'junior+software+developer',
    'junior+back+end+developer',
    'entry+level+developer',
    'junior+developer',
    'junior+full+stack+developer'
]

def search 
    print 'Enter a search term: '
    search_term = gets.chomp.split(' ').join('+')
    Scraper.new(search_term).run
end


if __FILE__ == $PROGRAM_NAME
    search
end