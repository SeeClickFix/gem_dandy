require_relative './gem_change'

module Depbot
  class DiffParser
    NAME_VERSION = /^(?<operation>[-+])\s+(?<name>[\w-]+)\s\([^\d.]*(?<version>[\d.]+)\)/

    def initialize(diff)
      @diff = diff || ''
    end

    def changes
      @changes ||= additions.map do |g|
        name = g['name']
        current_version = g['version']
        previous_version = previous_version_for(name)

        GemChange.new(name, previous_version, current_version)
      end
    end

    private

    attr_reader :diff

    def raw_changes
      @raw_changes ||= diff
                       .split("\n")
                       .map { |l| NAME_VERSION.match(l)&.named_captures }
                       .compact
    end

    def removals
      @removals ||= raw_changes.select { |c| c['operation'] == '-' }.uniq
    end

    def additions
      @additions ||= raw_changes.select { |c| c['operation'] == '+' }.uniq
    end

    def previous_version_for(name)
      previous_gem = removals.find { |old_gem| old_gem['name'] == name }
      previous_gem && previous_gem['version']
    end
  end
end
