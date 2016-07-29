require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'colorize'

BILIBILI = "http://www.bilibili.com"
PIXIV = "http://www.pixiv.net/"
BAIDU = "https://www.baidu.com"
ADDRESS = "https://h.nimingban.com/Forum"
MAX_DEPTH = 90
URL_MAX_LENGTH = 28
IMG_REQUIRE_SIZE_IN_BYTE = 1024 * 384

URLS = []
$count = 0
$visited_urls = {}

BAN_WORDS = [ "163", "qq", "gov", "acg", "123", "72g", "1688", "18", "dnf", "7", "youku", "people" ]

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

  content = open_remote_file( seed_url )
  return if !content

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
        puts ( url + '     ' + 'depth:' + depth.to_s ).red
        $visited_urls[url] = url
        search_page( url, depth + 1 )
      end
    end
  end
end

def download_img( img_url )
  return if !img_url

  content = open_remote_file(img_url)
  return if !content
  return if content.length < IMG_REQUIRE_SIZE_IN_BYTE

  $count += 1
  puts (img_url + '  ' + 'number:' + $count.to_s).green
  #return
  File.open( File.basename(img_url),'wb') do |f|
    f.write( (content).read )
  end
end

def open_remote_file(url)
  begin
    content = open(url, read_timeout: 5)
  rescue Exception=>e
    puts ("Error: #{e}" + "  :  " + url).yellow
    return
  ensure
    ###
  end

  content
end

search_page(BILIBILI)
#puts URLS
