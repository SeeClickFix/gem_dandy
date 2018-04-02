# frozen_string_literal: true

require_relative './env'
require 'fileutils'

module GemDandy
  class Bundler
    GEMFILE = 'Gemfile'
    LOCKFILE = 'Gemfile.lock'

    def initialize(base_dir)
      @base_dir = base_dir
      @gemfile = File.join(base_dir, GEMFILE)
      @lockfile = File.join(base_dir, LOCKFILE)
    end

    attr_reader :base_dir, :gemfile, :lockfile

    def update
      GemDandy::Env.temporarily_set('RUBYOPT', '') do
        FileUtils.chdir base_dir do
          GemDandy::Env.temporarily_set('BUNDLE_GEMFILE', gemfile) do
            system('bundle config --local frozen false')
            system('bundle lock --update')
          end
        end
      end
    end
  end
end
