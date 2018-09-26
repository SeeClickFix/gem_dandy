# frozen_string_literal: true

module GemDandy
  class YarnChangePresenter
    extend Forwardable

    def initialize(changeset)
      @changeset = changeset
    end

    def to_markdown
      if github_url
        [
          "#{name},",
          compare_changeset,
          changelog
        ].compact.join(' ')
      else
        "#{name}, #{changeset_range}"
      end
    end

    def name
      if github_url || homepage_url
        link_to changeset.name, github_url || homepage_url
      else
        changeset.name
      end
    end

    def changeset_range
      "#{previous_version}...#{current_version}"
    end

    def compare_changeset
      if compare_url
        link_to changeset_range, compare_url
      else
        changeset_range
      end
    end

    def changelog
      "(#{link_to 'CHANGELOG', changelog_url})" if changelog_url
    end

    private

    attr_reader :changeset

    def_delegators :changeset, :github_url, :compare_url, :changelog_url,
                   :homepage_url,
                   :current_version, :previous_version

    def link_to(text, url)
      "[#{text}](#{url})"
    end
  end
end
