# frozen_string_literal: true

require 'fileutils'
require 'json'

module GemDandy
  class Yarn
    LOCKFILE = 'yarn.lock'

    def initialize(base_dir)
      @base_dir = base_dir
      @lockfile = File.join(base_dir, LOCKFILE)
      @original_lock_json = load_lock_json
    end

    attr_reader :base_dir, :lockfile, :original_lock_json, :updated_lock_json

    def update
      FileUtils.chdir base_dir do
        system('yarn upgrade')
      end

      @updated_lock_json = load_lock_json
    end

    def original_package_versions
      @original_package_versions ||= package_versions(original_lock_json)
    end

    def updated_package_versions
      @updated_package_versions ||= package_versions(updated_lock_json)
    end

    def removed_packages
      original_package_versions.reject do |package|
        updated_package_versions.keys.include?(package)
      end
    end

    def added_packages
      updated_package_versions.reject do |package|
        original_package_versions.keys.include?(package)
      end
    end

    def changed_packages
      (original_package_versions.keys &
       updated_package_versions.keys).reject do |package|
        original_package_versions[package] ==
          updated_package_versions[package]
      end
    end

    private

    def load_lock_json
      JSON.parse(`bin/yarn_lock_to_json #{lockfile}`.strip)
    end

    def package_versions(package_set)
      package_versions = Hash.new { |hash, key| hash[key] = Set.new }

      package_set.each do |key, value|
        package_name = /(\S+)@.+$/.match(key).captures.first

        package_versions[package_name] << value['version']
      end

      package_versions
    end
  end
end
