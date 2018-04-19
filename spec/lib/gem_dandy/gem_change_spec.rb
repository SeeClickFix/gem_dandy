# frozen_string_literal: true

require 'gem_dandy/gem_change'
require 'webmock/rspec'

RSpec.describe GemDandy::GemChange do
  let(:name) { 'gem_dandy' }
  let(:previous_version) { '0.0.0' }
  let(:current_version) { '0.0.1' }

  let(:github_url) { 'https://github.com/seeclickfix/gem_dandy' }
  let(:changelog_url) { "#{github_url}/CHANGELOG.md" }

  subject { described_class.new(name, previous_version, current_version) }

  context 'rubygems info' do
    context 'when rubygems.org is unreachable or errors' do
      it 'fails gracefully', :aggregate_failures do
        stub_request(:get, GemDandy::GemChange::RUBYGEMS_API_URL_TEMPLATE).to_timeout

        expect(subject.homepage_url).to be_nil
        expect(subject.source_code_url).to be_nil
        expect(subject.github_url).to be_nil
        expect(subject.changelog_url).to be_nil
        expect(subject.compare_url).to be_nil
      end
    end

    context 'when rubygems.org returns non-json content' do
      it 'fails gracefully', :aggregate_failures do
        stub_request(:get, GemDandy::GemChange::RUBYGEMS_API_URL_TEMPLATE).to_return(
          body: 'This rubygem could not be found.',
          headers: { "content-type"=>"application/json" }
        )

        expect(subject.homepage_url).to be_nil
        expect(subject.source_code_url).to be_nil
        expect(subject.github_url).to be_nil
        expect(subject.changelog_url).to be_nil
        expect(subject.compare_url).to be_nil
      end
    end

    describe '#homepage_url' do
      let(:info_from_rubygems) { { 'homepage_uri' => homepage_uri } }

      context 'when homepage_uri is present' do
        let(:homepage_uri) { github_url }

        it 'returns the result' do
          allow(subject).to receive(:rubygems_info)
            .and_return(info_from_rubygems)

          expect(subject.homepage_url).to eq(homepage_uri)
        end
      end

      context 'when the homepage_uri is an empty string' do
        let(:homepage_uri) { '' }

        it 'returns nil' do
          allow(subject).to receive(:rubygems_info)
            .and_return(info_from_rubygems)

          expect(subject.homepage_url).to eq(nil)
        end
      end
    end

    describe '#source_code_url' do
      let(:info_from_rubygems) { { 'source_code_uri' => source_code_uri } }

      context 'when source_code_uri is present' do
        let(:source_code_uri) { github_url }

        it 'returns the result' do
          allow(subject).to receive(:rubygems_info)
            .and_return(info_from_rubygems)

          expect(subject.source_code_url).to eq(source_code_uri)
        end
      end

      context 'when the source_code_uri is an empty string' do
        let(:source_code_uri) { '' }

        it 'returns nil' do
          allow(subject).to receive(:rubygems_info)
            .and_return(info_from_rubygems)

          expect(subject.source_code_url).to eq(nil)
        end
      end
    end
  end

  describe '#github_url' do
    context 'with no homepage_url or source_code_url' do
      it 'returns nil' do
        allow(subject).to receive(:homepage_url).and_return(nil)
        allow(subject).to receive(:source_code_url).and_return(nil)

        expect(subject.github_url).to eq(nil)
      end
    end

    context 'with a homepage_url and source_code_url not on github' do
      let(:non_github_url) { 'http://bitbucket.com/seeclickfix/gem_dandy' }

      it 'returns nil' do
        allow(subject).to receive(:homepage_url).and_return(non_github_url)
        allow(subject).to receive(:source_code_url).and_return(non_github_url)

        expect(subject.github_url).to eq(nil)
      end
    end

    context 'with a homepage_url or source_code_url on github' do
      it 'returns the first matched github url' do
        allow(subject).to receive(:homepage_url).and_return(github_url)
        allow(subject).to receive(:source_code_url).and_return(github_url)

        expect(subject.github_url).to eq(github_url)
      end
    end
  end

  describe '#changelog_url' do
    it 'delegates to Github::Changelog.for' do
      allow(subject).to receive(:github_url).and_return(github_url)
      allow(GemDandy::Github::Changelog).to receive(:for)
        .and_return(changelog_url)

      expect(subject.changelog_url).to eq(changelog_url)
      expect(GemDandy::Github::Changelog).to have_received(:for)
        .with('seeclickfix/gem_dandy', 'v0.0.1')
    end
  end

  describe '#compare_url' do
    context 'without a github_url' do
      it 'returns nil' do
        allow(subject).to receive(:github_url).and_return(nil)

        expect(subject.compare_url).to eq(nil)
      end
    end

    context 'with a github_url' do
      it 'returns a compare url for the two versions' do
        allow(subject).to receive(:github_url).and_return(github_url)

        expect(subject.compare_url).to include(github_url)
          .and include('compare')
          .and include(previous_version)
          .and include(current_version)
      end
    end
  end

  describe '#to_markdown' do
    context 'with no github_url' do
      it 'returns the gem name and version change information' do
        allow(subject).to receive(:github_url).and_return(nil)

        expect(subject.to_markdown).to include(name)
          .and include(previous_version)
          .and include(current_version)
      end
    end

    context 'with a github_url' do
      before do
        allow(subject).to receive(:github_url).and_return(github_url)
        allow(subject).to receive(:changelog_url).and_return(nil)
      end

      it 'returns valid markdown markup'

      it 'returns the gem name and version change information' do
        expect(subject.to_markdown).to include(name)
          .and include(previous_version)
          .and include(current_version)
      end

      it 'returns a link to github' do
        expect(subject.to_markdown).to include(github_url)
      end

      it 'returns a link to the version comparison' do
        expect(subject.to_markdown).to include(subject.compare_url)
      end

      context 'with a changelog' do
        it 'returns a link to the changelog' do
          allow(subject).to receive(:changelog_url).and_return(changelog_url)

          expect(subject.to_markdown).to include(changelog_url)
        end
      end
    end
  end
end
