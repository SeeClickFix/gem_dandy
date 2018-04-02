# frozen_string_literal: true

require 'stringio'

module GemDandySpecHelpers
  def silence_output
    previous_stderr = $stderr.clone
    previous_stdout = $stdout.clone
    $stdout.reopen(File.new('/dev/null', 'w'))
    $stderr.reopen(File.new('/dev/null', 'w'))

    yield
  ensure
    $stderr.reopen(previous_stderr)
    $stdout.reopen(previous_stdout)
  end
end
