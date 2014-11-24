module MiniSpec
  module InstanceAPI

    # @return [Array]
    attr_reader :__ms__failures

    attr_accessor :__ms__inside_helper

    (MiniSpec::AFFIRMATIONS + MiniSpec::NEGATIONS).each do |left_method|
      # defining methods that will proxy tested object.
      # methods accepts either a single argument or no arguments at all.
      # if no arguments nor block given, it will use `subject` as test object(@see #subject).
      # if block given it will have priority over both arguments and subject.
      #
      # @example test object passed into `is` proxy via first argument
      #   is(1) < 2
      #
      # @example test object passed into `does` proxy via block
      #   does { some_array }.include? some_value
      #
      # @param *args
      # @return [MiniSpec::Proxy] a proxy instance
      #   that will send all received messages to tested object and track the result
      #
      define_method left_method do |*args, &proc|
        Minispec.assertions += 1
        MiniSpec::Utils.valid_proxy_arguments?(left_method, *args, &proc)
        __ms__inside_helper ? @__ms__callers.push(caller[0]) : @__ms__callers = [caller[0]]
        # using args#size rather than args#any? cause first argument can be nil or false
        left_object = args.size > 0  ? args.first : self.subject
        negate  = MiniSpec::NEGATIONS.include?(left_method)
        failure_message = args[1].is_a?(Hash) ?
          args[1][:message] || args[1][:failure] || args[1][:error] :
          nil
        MiniSpec::Proxy.new(self, left_method, left_object, negate, failure_message, &proc)
      end
    end

    # this will be overridden when the spec are defined using Minispec's DSL
    #
    # @example
    #   describe Hash do
    #     # subject will be set to Hash
    #     it 'responds to :[]' do
    #       assert.respond_to?(:[]) # same as assert(Hash).respond_to?(:[])
    #     end
    #   end
    #
    def subject; end

    # stop evaluation of the current test right away
    #
    # @example
    #   test :some_test do
    #     is(1) < 2
    #     skip
    #     is(1) > 2 # this wont be evaluated so the test will pass
    #   end
    #
    def skip
      @__ms__skipped = caller.first
      throw :__ms__stop_evaluation
    end
    alias skip! skip

    def __ms__skipped?; @__ms__skipped end

    # adds a new failure to the stack.
    # a failure is a Hash containing keys like
    #   :message
    #   :left_method
    #   :left_object
    #   :right_method
    #   :right_object
    #   :negation
    #   :callers
    # used by MiniSpec::Run#failures_summary and MiniSpecRun#failure_message
    # to output useful info about failed tests.
    #
    # @param failure  if failure is `nil` or `false` it simply returns.
    #                 unless failure is a Hash it is building a Hash like
    #                 {message: failure} and adding it to the stack.
    # @return [Array] failures stack
    def fail failure = {}
      return unless failure
      unless failure.is_a?(Hash)
        failure || raise(ArgumentError, 'Please provide a failure message')
        failure = {message: failure}
      end
      @__ms__failures << failure.merge(callers: @__ms__callers)
      throw :__ms__stop_evaluation unless self.class.continue_on_failures?
    end
    alias fail! fail

    # @api private
    # setting/resetting all necessary instance variables
    # for a test to run in clean state
    def __ms__prepare_test
      @__ms__vars     = {}
      @__ms__failures = []
      @__ms__skipped  = nil
      __ms__mocks__reset_variables
    end

    def __ms__mocks__reset_variables
      @__ms__messages          = []
      @__ms__proxies           = {}
      @__ms__stubs             = {}
      @__ms__stubs__originals  = {}
      @__ms__expectations      = []
    end

    def __ms__run_test label
      Minispec.tests += 1
      __ms__prepare_test
      runner = proc do
        # running :before hooks, if any
        self.class.before?(label).each {|(l,m,b)| instance_exec(l,m,&b)}

        # running test
        catch :__ms__stop_evaluation do
          instance_exec(&self.class.tests[label].last)
        end

        # running :after hooks, if any
        self.class.after?(label).each {|(l,m,b)| instance_exec(l,m,&b)}
      end

      if around = self.class.around?(label).last
        self.instance_exec(runner, &around.last)
      else
        runner.call
      end

      __ms__mocks__validate_expectations
      __ms__mocks__restore_originals
      @__ms__failures
    rescue Exception => e
      [e]
    ensure
      __ms__mocks__reset_variables
    end

    # runs before any tests
    def __ms__boot
      __ms__prepare_test
      (hook = self.class.before_all?) && self.instance_exec(&hook)
    end

    # runs after all tests finished.
    # runs unconditionally even when there are failed tests.
    def __ms__halt
      (hook = self.class.after_all?) && self.instance_exec(&hook)
    end
  end
end

Dir[File.expand_path('../instance/**/*.rb', __FILE__)].each {|f| require(f)}
