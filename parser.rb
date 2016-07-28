require 'rubygems'
require 'nokogiri'
require 'open-uri'

BILIBILI = "http://www.bilibili.com"
PIXIV = "http://www.pixiv.net/"
BAIDU = "https://www.baidu.com"
ADDRESS = ""
MAX_DEPTH = 20
URL_MAX_LENGTH = 30

URLS = []
$count = 0
$visited_urls = {}

BAN_WORDS = [ "163", "qq", "gov", "acg", "123", "72g", "1688", "18", "dnf", "7" ]

def valid_url?( url )
  url ||= ""
  url =~ /^http:/
end

def valid_length?( text )
  return true if text.length <= URL_MAX_LENGTH
  false
end

def include_ban_words?(text)
  BAN_WORDS.each do |word|
    if( text.include?(word) )
      return true
    end
  end
  return false
end

def search_page( seed_url, depth = 0 )
  if depth >= MAX_DEPTH
    return
  end

  begin
    content = open(seed_url, read_timeout: 5)
  rescue Exception=>e
    puts "Error: #{e}" + "  :  " + seed_url
    sleep 1
    return
  ensure
    ######
  end

  parse_body( content, depth )

end

def parse_body( content, depth )
  page = Nokogiri::HTML(content)

  imgs = page.css('img').select{ |img| img['src'] =~ /^http:.+[.jpg|.png]$/ }
  imgs.each do |img|
    download_img( img['src'] ) if img['src']
  end

  links = page.css('a')
  links.each do |link|
    url = link['href']
    if valid_url?(url)
      if( !$visited_urls[url] && valid_length?(url) && !include_ban_words?(url) )
        #puts url + '     ' + depth.to_s
        $visited_urls[url] = url
        search_page( url, depth + 1 )
      end
    end
  end
end

def download_img( img_url )
  return if !img_url
  puts img_url

  begin
    content = open(img_url, read_timeout: 5)
  rescue Exception=>e
    puts "Error: #{e}" + "  :  " + seed_url
    sleep 1
    return
  ensure
    ######
  end

  File.open( File.basename(img_url),'wb') do |f|
    f.write( (content).read )
  end

end

search_page(BILIBILI)
#puts URLS
