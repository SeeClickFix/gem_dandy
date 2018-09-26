# frozen_string_literal: true

require 'httparty'
require 'json'
require_relative './github/changelog'
require_relative './yarn_change_presenter'

module GemDandy
  class YarnChange
    NPMJS_API_URL_TEMPLATE = Addressable::Template.new('https://registry.npmjs.org/{name}/{version}').freeze

    def initialize(name, previous_version, current_version)
      @name = name
      @previous_version = previous_version
      @current_version = current_version
      @previous_tag = "v#{previous_version}"
      @current_tag = "v#{current_version}"
    end

    attr_reader :name, :previous_version, :current_version

    def homepage_url
      @homepage_url ||= url_for('homepage')
    end

    def repository_url
      @repository_url ||= begin
        repo = npmjs_info['repository']

        return unless repo

        if String === repo
          repo
        elsif Hash === repo
          repo['url']
        else
          raise "Unknown Repo format #{repo.inspect}"
        end
      end
    end

    def github_url
      "#{GemDandy::Github::URL}/#{github_repo}" if github_repo
    end

    def changelog_url
      @changelog_url ||= Github::Changelog.for(github_repo, current_tag)
    end

    def compare_url
      return unless github_url
      return if current_version.nil? || previous_version.nil?

      "#{github_url}/compare/#{previous_tag}...#{current_tag}"
    end

    def to_markdown
      GemDandy::YarnChangePresenter.new(self).to_markdown
    end

    private

    attr_reader :previous_tag, :current_tag

    def npmjs_info
      @npmjs_info ||= begin
        response = HTTParty.get(NPMJS_API_URL_TEMPLATE.expand(name: name))
        body = response.body

        begin
          body.encode(Encoding::UTF_8)
        rescue Encoding::UndefinedConversionError
          body.force_encoding(Encoding::UTF_8)
        end

        json_response = JSON.parse(body)

        if String === json_response
          binding.irb
        end

        version = json_response.dig('versions', current_version || previous_version)

        if version
          version
        else
          puts "No npm info found for #{name}@#{current_version}"
          {}
        end
      end
    end

    def url_for(key)
      url = npmjs_info[key]

      url && url != '' ? url : nil
    end

    def github_repo
      url = [repository_url, homepage_url].find { |u| u && u[/github.com/] }

      url && %r{github.com\/([\w-]+\/[\w-]+)}.match(url)&.captures&.first
    end
  end
end
