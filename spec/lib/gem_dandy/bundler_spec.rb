# frozen_string_literal: true

require 'gem_dandy/bundler'
require 'tmpdir'
require 'diffy'

RSpec.describe GemDandy::Bundler do
  include GemDandySpecHelpers

  let(:base_dir) { @dir }
  let(:original_lockfile) { File.read('spec/support/Gemfile.lock') }
  let(:updated_lockfile) { File.read(File.join(base_dir, GemDandy::Bundler::LOCKFILE)) }
  let(:diff) { Diffy::Diff.new(original_lockfile, updated_lockfile).diff }

  subject { described_class.new(base_dir) }

  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir

      [GemDandy::Bundler::GEMFILE, GemDandy::Bundler::LOCKFILE].each do |file|
        FileUtils.cp(File.join('spec', 'support', file), File.join(dir, file))
      end

      example.run
    end
  end

  it 'updates the Gemfile.lock in place' do
    silence_output do
      subject.update
    end

    expect(diff).to include('-    prawn (2.2.1)')
    expect(diff).to include('+    prawn (') # Super relaxed check here
  end
end
