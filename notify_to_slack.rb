#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'slack-notifier'

WEBHOOK_URL = ''

class Keyword
  attr_reader :query, :ignores

  def initialize(queries = [], ignores = [])
    @query   = Array(queries).join(' ').gsub(' ', '+')
    @ignores = Array(ignores)
  end

  class << self
    def list
      res = []
      res << self.new(['hogeニュース'], ['piyo'])
      res
    end
  end
end

class YahooTv
  YAHOO_TV_URL = 'https://tv.yahoo.co.jp'

  class << self
    def notify(notifier, keyword_list)
      messages = []

      keyword_list.each do |keyword_obj|
        url     = build_url(keyword_obj.query)
        message = ''

        doc = Nokogiri::HTML(open(url))
        doc.css('.programlist > li').each do |element|
          a_tag = element.css('.rightarea > p > a').first
          title = a_tag.inner_text

          next if keyword_obj.ignores.any? { |key| title.match?(key) }

          message = '=' * 30 + "\n" * 2

          # 日時
          element.css('.leftarea > p > em').each do |em|
            message += "#{em.inner_text} "
          end

          # 放送局
          message += element.css('.rightarea > p > span').first.inner_text
          message += "\n"

          # 番組名
          message += "*#{title}*"
          message += "\n"

          # 概要
          message += "```"
          message += element.css('.rightarea > p').search(':not(:has(a,span))').inner_text
          message += "```"
          message += "\n"

          # URL
          message += "#{YAHOO_TV_URL}#{a_tag['href']}"
          message += "\n" * 2

          messages << message
        end
      end

      notifier.ping messages.join("\n") unless messages.empty?
    end

    private

    # a: 東京
    # d: 日付
    # t: 1(BS), 3(地上波)
    def build_url(query)
      "#{YAHOO_TV_URL}/search/?q=#{URI.encode(query)}&a=23&t=1%203&oa=1&d=#{Time.now.strftime('%Y%m%d')}"
    end
  end
end

notifier = Slack::Notifier.new WEBHOOK_URL
YahooTv.notify(notifier, Keyword.list)
