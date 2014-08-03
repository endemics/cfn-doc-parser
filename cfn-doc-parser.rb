#!/usr/bin/ruby -w

require 'nokogiri'
require 'open-uri'

def parse_page(url)
  h = { :i => {}, :r => {}, :n => {} }
  doc = Nokogiri::HTML(open(url))
  # properties are in a list (dl) as dt for the key and dd for the content
  properties = doc.search('//div[@class="variablelist"]/dl')
  properties.search('dt').each do |dt|
    property = dt.text

    dd = dt.next_element
    dd.search('p').each do |p|
      if p.text.include?'Update requires'
        effect = p.text.sub('Update requires:','')
        if effect.include?'Replacement'
          h[:r][property.to_sym] = effect
        end
        if effect.include?'Some interruptions'
          h[:i][property.to_sym] = effect
        end
        if effect.include?'No interruption'
          h[:n][property.to_sym] = effect
        end
      end
    end
  end
  h
end

aws_doc_root = 'http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/'
aws_pages = ['aws-properties-cloudfront-distribution.html', 'aws-properties-ec2-instance.html']
aws_pages = [
  'aws-properties-ec2-instance.html',
  'aws-properties-cloudfront-distribution.html'
]

aws_pages.each do |page|
  p parse_page("#{aws_doc_root}#{page}")
end
