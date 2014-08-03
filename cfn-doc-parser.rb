#!/usr/bin/ruby -w

require 'nokogiri'

h = { :r => {}, :i => {}, :n => {} }
file =  File.new('aws-properties-ec2-instance.html')
doc = Nokogiri::HTML(file)

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
p h
