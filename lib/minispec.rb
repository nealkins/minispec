require 'stringio'
require 'pp'
require 'coderay'
require 'diff/lcs'
require 'diff/lcs/hunk'

# private module.
# for internal use only.
module MiniSpec
  extend self

  # files loading pattern. relative to `Dir.pwd`
  DEFAULT_PATTERN = "{spec,test}/**/{*_spec.rb,*_test.rb,test_*.rb}".freeze

  SPEC_WRAPPERS = %w[
    describe
    context
    section
  ].freeze

  TEST_WRAPPERS = %w[
    test
    testing
    example
    should
    it
  ].freeze

  IMPORTABLES = %w[
    tests
    helpers
    before
    after
    around
    vars
    continue_on_failures
  ].map(&:to_sym).freeze

  AFFIRMATIONS = %w[
    is   is?
    are  are?
    was  was?
    does does?
    did  did?
    have have?
    has  has?
    assert
    affirm
    assume
    assure
    expect
    verify
    check
    prove
    would
    will
  ].freeze

  NEGATIONS = %w[
    refute
    negate
    fail_if
    not_expected
    assert_not
  ].freeze


  def source_location_cache file
    return unless File.file?(file) && File.readable?(file)
    (@source_location_cache ||= {})[file] ||= File.readlines(file)
  end
end

MiniSpec::SPEC_WRAPPERS.each do |meth|
  # top-level methods that allows to define specs using Minispec's DSL
  #
  # @example
  #
  #   describe SomeSpec do
  #     # some tests
  #   end
  #
  #   describe SomeAnotherSpec do
  #     # some another tests
  #   end
  #
  define_method meth do |subject, &proc|
    spec_name = subject.to_s.freeze
    spec = Class.new do
      include Minispec
      define_method(:subject) { subject }
      # set spec name before executing the proc
      # otherwise wrong spec name will be reported
      define_singleton_method(:spec_name)     { spec_name }
      define_singleton_method(:spec_fullname) { spec_name }
      define_singleton_method(:spec_proc)     { proc      }
      define_singleton_method(:indent)        { 0         }
    end
    spec.class_exec(&proc)
  end
end

require 'minispec/utils'
require 'minispec/mocks'
require 'minispec/proxy'
require 'minispec/reporter'
require 'minispec/api'

# public module.
# to be used for inclusions by end users.
module Minispec
  # extending Minispec module with MiniSpec::ClassAPI
  # to be able to define global shared resources
  #
  # @example
  #  module Minispec
  #    around do
  #      # all specs includes Minispec module
  #      # so all tests will run inside this block
  #    end
  #
  #    def some_utility_method
  #      # all specs will have this method
  #    end
  #
  #    # etc
  #  end
  #
  extend MiniSpec::ClassAPI

  class << self
    attr_accessor :specs, :tests, :assertions

    def included base
      base.extend(MiniSpec::ClassAPI)
      base.send(:include, MiniSpec::InstanceAPI)

      # inserting global shared resources defined inside Minispec module
      MiniSpec::IMPORTABLES.each do |importable|
        base.send('import_%s' % importable, self)
      end

      specs.push(base) unless specs.include?(base)
    end

    def run opts = {}
      files = opts[:files] || opts[:file]
      files ||= File.basename($0) == 'minispec' && $*.any? && $*
      files ||= Dir[File.join(Dir.pwd, opts[:pattern] || MiniSpec::DEFAULT_PATTERN)]
      files = [files] unless files.is_a?(Array)

      $:.include?(Dir.pwd) || $:.unshift(Dir.pwd)
      lib = File.join(Dir.pwd, 'lib')
      !$:.include?(lib) && File.directory?(lib) && $:.unshift(lib)

      pwd = /\A#{Regexp.escape(Dir.pwd)}\//.freeze
      files.each do |f|
        path = File.expand_path(File.dirname(f), Dir.pwd).sub(pwd, '')
        path = File.join(Dir.pwd, path.split('/').first)
        $:.include?(path) || $:.unshift(path)
        require(f)
      end
      reporter = opts[:reporter] || MiniSpec::Reporter.new
      specs.each {|s| s.run(reporter)}
      reporter.summary
      exit(1) if reporter.failures?
    end
  end
end

Minispec.specs      = []
Minispec.tests      = 0
Minispec.assertions = 0

require 'minispec/helpers'
