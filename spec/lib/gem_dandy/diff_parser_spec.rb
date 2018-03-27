# frozen_string_literal: true

require 'gem_dandy/diff_parser'

RSpec.describe GemDandy::DiffParser do
  subject { described_class.new(@diff) }

  describe '#changes' do
    it 'currently ignores git revision changes' do
      @diff = '+  revision: 1ea84f2ab40181616944983c4ca5e0d98670af76'

      expect(subject.changes).to be_empty
    end

    it 'ignores lines that are not gems' do
      @diff = "this is bogus\ndiff\nindex\n@@"

      expect(subject.changes).to be_empty
    end

    it 'includes any new gems added' do
      @diff = '+    new_gem (0.1.0)'

      new_gem = subject.changes.first

      expect(new_gem.name).to eq('new_gem')
      expect(new_gem.current_version).to eq('0.1.0')
      expect(new_gem.previous_version).to eq(nil)
    end

    it 'only returns unique gems' do
      @diff = "+    new_gem (0.1.0)\n+    new_gem (0.1.0)"

      expect(subject.changes.count).to eq(1)
    end

    it 'includes the previous gem version if found' do
      @diff = "+    new_gem (0.1.0)\n-    new_gem (0.0.9)"

      gem_change = subject.changes.first

      expect(gem_change.previous_version).to eq('0.0.9')
    end

    it 'ignores dependency changes' do
      @diff = '+      dep_gem (0.1.0)'

      expect(subject.changes).to be_empty
    end
  end
end
