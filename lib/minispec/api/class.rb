module MiniSpec
  module ClassAPI

    # @example
    #    module CPUTests
    #      include Minispec
    #
    #      # CPU related tests
    #    end
    #
    #    module RAMTests
    #      include Minispec
    #
    #      # RAM related tests
    #    end
    #
    #    describe :MacBook do
    #      include CPUTests
    #      include RAMTests
    #
    #      # will run CPU and RAM tests + any tests defined here
    #    end
    #
    def included base
      base.send(:include, Minispec)
      MiniSpec::IMPORTABLES.each do |importable|
        base.send('import_%s' % importable, self)
      end
    end

    # @example
    #    module CPUTests
    #      include Minispec
    #
    #      # CPU related tests
    #    end
    #
    #    module RAMTests
    #      include Minispec
    #
    #      # RAM related tests
    #    end
    #
    #    describe :MacBook do
    #      include CPUTests
    #      include RAMTests
    #
    #      # we do not need :around hook nor included variables
    #      reset :around, :vars
    #
    #      # will run CPU and RAM tests + any tests defined here
    #    end
    #
    def reset *importables
      importables.each do |importable|
        MiniSpec::IMPORTABLES.include?(inheritable.to_sym) || raise(ArgumentError,
          'Do not know how to reset %s. Use one of %s' % [inheritable.inspect, MiniSpec::IMPORTABLES*', '])
        self.send('reset_%s' % inheritable)
      end
    end

    # by default MiniSpec will stop evaluating a test on first failed assertion.
    # `continue_on_failures true` will make MiniSpec continue evaluating regardless failures.
    #
    # @example set globally
    #
    #   MiniSpec.setup do
    #     continue_on_failures true
    #   end
    #
    # @example set per spec
    #
    #   describe SomeTest do
    #     continue_on_failures true
    #
    #     # ...
    #   end
    #
    def continue_on_failures status
      @continue_on_failures = status
    end
    def continue_on_failures?
      @continue_on_failures
    end

    def import_continue_on_failures base
      import_instance_variable(:continue_on_failures, base)
    end
    alias import_continue_on_failures_from import_continue_on_failures

    def reset_continue_on_failures
      remove_instance_variable(:@continue_on_failures)
    end

    def hooks_filter callbacks, filter
      return callbacks unless filter
      callbacks.map do |(matchers,proc)|
        MiniSpec::Utils.any_match?(filter, matchers) ? [filter, matchers, proc] : nil
      end.compact
    end

    def import_instance_variable var, base
      return unless base.instance_variable_defined?('@%s' % var)
      val = base.instance_variable_get('@%s' % var)
      val.is_a?(Proc) ? send(var, &val) : send(var, val)
    end

    MiniSpec::SPEC_WRAPPERS.each do |meth|
      # used to define nested specs
      #
      # inner specs will not share any of its stuff with parent spec
      # nor will affect parent's state in any way,
      # i.e. wont override any variables, setups nor tests etc.
      # that's it, a inner spec is a isolated closure.
      #
      # @note  if these methods used inside a class that included Minispec,
      #   the created spec will use parent spec as superclass.
      #
      # @example
      #   describe :Math do
      #
      #     # Math tests
      #
      #     describe :PI do
      #       # PI tests
      #     end
      #   end
      #
      define_method meth do |subject, opts = {}, &proc|
        spec_name     = subject.to_s.freeze
        spec_fullname = [self.spec_fullname, spec_name].join(' / ').freeze
        indent = self.indent + 2
        args   = self.is_a?(Class) && self.include?(Minispec) ? [self] : []
        spec   = Class.new *args do
          include Minispec
          define_method(:subject) { subject }
          # set spec name before executing the proc
          # otherwise wrong spec name will be reported in failures
          define_singleton_method(:spec_name)     { spec_name     }
          define_singleton_method(:spec_fullname) { spec_fullname }
          define_singleton_method(:spec_proc)     { proc          }
          define_singleton_method(:indent)        { indent        }
        end
        MiniSpec::IMPORTABLES.reject {|i| i == :tests}.each do |importable|
          spec.send('import_%s' % importable, self)
        end
        spec.class_exec(&proc)
      end
    end

    def spec_name; self.name    end
    alias :spec_fullname :spec_name
    def spec_proc; nil          end
    def indent;    0            end

    def run reporter
      reporter.puts(spec_name, indent: indent)
      instance = self.allocate
      runner   = proc do
        instance.__ms__boot
        tests.each_pair do |label,(verb,proc)|
          reporter.print('%s %s ' % [verb, label], indent: indent + 2)

          failures = instance.__ms__run_test(label)

          if skipped = instance.__ms__skipped?
            reporter.mark_as_skipped(spec_name, label, skipped)
            next
          end

          if failures.empty?
            reporter.mark_as_passed(spec_name, label)
            next
          end

          reporter.mark_as_failed(spec_fullname, label, verb, proc, failures)
        end
        instance.__ms__halt
      end
      if around_all = around_all?
        instance.instance_exec(runner, &around_all)
      else
        runner.call
      end
      reporter
    rescue Exception => e
      # catch exceptions raised inside :before_all/:after_all/:around_all hooks.
      # exceptions raised inside tests are caught by instance#__ms__run_test
      reporter.failed_specs << [spec_name, spec_proc, e]
      reporter
    end
  end
end

Dir[File.expand_path('../class/**/*.rb', __FILE__)].each {|f| require(f)}
