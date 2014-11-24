require 'minitest/autorun'
require 'minispec'

class Reporter < MiniSpec::Reporter
  attr_reader :status

  def initialize(*)
    super
    @status = {}
  end

  def mark_as_passed spec, test
    super
    @status[test] = 0
  end

  def mark_as_skipped spec, test, source
    super
    @status[test] = -1
  end

  def mark_as_failed spec, test, verb, proc, failures
    super
    @status[test] = 1
  end
end

class SilentReporter < Reporter
  def puts(*); end
  alias print puts
end

def msrun spec, verbose = false
  reporter = verbose ? Reporter.new : SilentReporter.new
  spec.run(reporter)
  reporter.summary if verbose
  reporter
end

class MinispecTest < Minitest::Test
  def self.define_tests unit
    result = msrun(unit)
    unit.tests.each_pair do |test,(_,proc)|
      status = test =~ /:fail/ ? 1 : 0
      define_method 'test_ %s: %s' % [unit, test] do
        assert_equal(status, result.status[test], proc.source_location)
      end
    end
  end

  class Expectations < self
  end
end
