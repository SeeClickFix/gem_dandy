require_relative './github/changelog'
require 'httparty'

module Depbot
  class GemChange
    RUBYGEMS_API_URL = 'https://rubygems.org/api/v1/gems'.freeze

    def initialize(name, previous_version, current_version)
      @name = name
      @previous_version = previous_version
      @current_version = current_version
      @previous_tag = "v#{previous_version}"
      @current_tag = "v#{current_version}"
    end

    attr_reader :name, :previous_version, :current_version

    def homepage_url
      @homepage_url ||= url_for('homepage_uri')
    end

    def source_code_url
      @source_code_url ||= url_for('source_code_uri')
    end

    def github_url
      [homepage_url, source_code_url].find { |url| url && url[/github.com/] }
    end

    def changelog_url
      @changelog_url ||= Github::Changelog.for(github_repo, current_tag)
    end

    def compare_url
      return unless github_url

      "#{github_url}/compare/#{previous_tag}...#{current_tag}"
    end

    def to_markdown
      link = ->(text, url) { "[#{text}](#{url})" }

      if github_url
        [
          link.call(name, github_url),
          ', ',
          link.call([previous_version, current_version].join('...'),
                    compare_url),
          (" (#{link.call('CHANGELOG', changelog_url)})" if changelog_url)
        ].join
      else
        "#{name}, #{previous_version}...#{current_version}"
      end
    end

    private

    attr_reader :previous_tag, :current_tag

    def rubygems_info
      @rubygems_info ||= HTTParty.get("#{RUBYGEMS_API_URL}/#{name}.json")
    end

    def url_for(key)
      url = rubygems_info[key]

      url && url != '' ? url : nil
    end

    def github_repo
      return unless github_url

      %r{github.com\/([\w-]+\/[\w-]+)}.match(github_url)&.captures&.first
    end
  end
end
