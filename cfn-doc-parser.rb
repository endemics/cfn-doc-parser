#!/usr/bin/ruby -w

require 'nokogiri'
require 'open-uri'
require 'json'

# All the documentation pages are attached to this URL
aws_doc_root = 'http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/'

def parse_page(url)
  doc = Nokogiri::HTML(open(url))
  # Extract the topic from the page
  topic = doc.search('//h1[@class="topictitle"]')
  h = {}
  # properties are in a list (dl) as dt for the key and dd for the content
  properties = doc.search('//div[@class="variablelist"]/dl')
  properties.search('dt').each do |dt|
    property = dt.text

    # Let's assume the dd is the next element (risky but seems to work)
    dd = dt.next_element
    # the dd will have several paragraphs (p resources)
    # go through each and find for the one containing the string 'Update requires'
    # //*[@id="divContent"]/div[1]/div[3]/div[2]/dl/dd[4]/p[5]/span/em
    dd.search('p').each do |p|
      # p.search('em')
      if p.text.include?'Update requires'
        effect = p.text.sub('Update requires:','').sub("\n", '')
        if /^ No interruption\.*$/.match(effect)
          h[property.to_sym] = { 'nointerruption'.to_sym => effect }
        elsif /^ Replacement\.*$/.match(effect)
          h[property.to_sym] = { 'replacement'.to_sym => effect }
        elsif /^ Some interruptions$/.match(effect)
          h[property.to_sym] = { 'someinterruption'.to_sym => effect }
        else
          h[property.to_sym] = { 'unknown'.to_sym => effect }
        end
      end
    end
  end
  { :name => topic.text, :value => h }
end

def get_all_cfn_pages(base_url)
  pages = []

  topic_page = 'aws-template-resource-type-ref.html'
  doc = Nokogiri::HTML(open("#{base_url}/#{topic_page}"))
  page_list = doc.search('//*[@id="divContent"]/div[1]/div[2]/ul')
  page_list.search('li').each do |rsc|
    pages << rsc.search('a/@href').first.value
  end
  return pages
end

aws_pages = get_all_cfn_pages(aws_doc_root)
result = {}
aws_pages.each do |page|
  h = parse_page("#{aws_doc_root}#{page}")
  result[h[:name]] = h[:value]
end
puts JSON.pretty_generate(result)
