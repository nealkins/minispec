module MiniSpec
  class Proxy

    @@negations = [
      :not,
      :to_not,
      :has_not,
      :have_not,
      :does_not,
      :did_not,
      :is_not,
      :is_not_a,
      :wont,
    ].freeze

    # initializes a new proxy instance
    # that will forward all received messages to tested object.
    #
    # @param base spec instance
    # @param left_method  the method on spec instance that accepts tested object,
    #   eg: is(...), does(...) etc.
    # @param left_object  tested object itself
    # @param negation  if set to a positive value assertion will be marked as failed if passed
    # @param &proc  if block given, it will be yielded(at a later point)
    #   and returned value will be used as tested object.
    def initialize *args, &proc
      @base, @left_method, @left_object, @negation, @failure_message = args
      @left_proc = proc
      @sugar = []
    end

    instance_methods.each do |m|
      # overriding all instance methods so they point to tested object
      # rather than to proxy instance.
      # simply returns if no spec instance set.
      #
      # @example  checking whether `foo` if frozen.
      #   is(:foo).frozen?
      #   # `is` will initialize and return a MiniSpec::Proxy instance with :foo passed into it.
      #   # MiniSpec::Proxy instance is receiving `frozen?` message and sending it to :foo.
      #
      define_method m do |*a, &p|
        @base && __ms__assert(m, *a, &p)
      end
    end

    # any missing method will be forwarded to #__ms__assert.
    # simply returns if no spec instance set.
    #
    # @example checking whether `some_array` include `foo`
    #   does(some_array).include? foo
    #   # MiniSpec::Proxy instance does not respond to `include?`, so it is passed to `some_array`
    def method_missing m, *a, &p
      @base && __ms__assert(m, *a, &p)
    end

    %w[
      a
      is
      is_a
      are
      will
      was
      does
      did
      have
      has
      to
      be
      been
    ].each do |m|
      # sugar methods that returns proxy instance.
      #
      # @example `a` serve as a bridge between tested object and `instance_of?` message
      #   is(foo).a.instance_of?(Foo)
      #
      # @return [MiniSpec::Proxy] proxy instance
      define_method(m) { @sugar.push(m); self }
    end

    # sugar methods that sets negation bit and returns proxy instance.
    #
    # @example `is_not_a` will set negation bit and return current proxy instance.
    #   assure(this).is_not_a.instance_of? That
    #
    # @return [MiniSpec::Proxy] proxy instance
    @@negations.each do |verb|
      define_method(verb) { @negation = true; self }
    end

    # the core of MiniSpec assertion methodology.
    # all tested objects arrives this point where they receive testing messages.
    #
    # @param right_method  message to be sent to tested object.
    #   if there is a helper with such a name, the helper are run and result returned.
    # @param *args  arguments to be passed to tested object when message sent.
    # @param &right_proc  block to be passed to tested object when message sent.
    # @return if some helper matched first argument returns helper's execution result.
    #   returns `nil` if test passed.
    #   returns a failure if test failed.
    def __ms__assert right_method, *args, &right_proc
      if helper = @base.class.helpers[right_method]
        return __ms__run_helper(helper, *args, &right_proc)
      end

      result = __ms__send(right_method, *args, &right_proc)

      if @negation           # sometimes
        return unless result # verbosity
      else                   # is
        return if result     # a
      end                    # virtue

      __ms__fail(right_method, right_proc, *args)
    end

    # passing received message to tested object
    def __ms__send right_method, *args, &right_proc
      __ms__left_object.__send__(right_method, *args, &right_proc)
    end

    # executes a helper block earlier defined at class level
    #
    # @param  helper  helper name
    # @param  *args   arguments to be passed into helper block
    def __ms__run_helper helper, *args, &right_proc
      helper_proc, helper_opts = helper
      args.unshift(@left_proc || @left_object)
      args.push(right_proc) if right_proc
      args << {
        left_method: @left_method,
        left_object: @left_object,
          left_proc: @left_proc,
         right_proc: right_proc,
           negation: @negation
      }.freeze if helper_opts[:with_context]
      @base.__ms__inside_helper = true
      @base.instance_exec(*args, &helper_proc)
    ensure
      @base.__ms__inside_helper = false
    end

    # computes tested object based on arguments passed at initialize.
    # if a block given it is yielded and returned value used as tested object.
    # otherwise orig `@left_object` used.
    # if given block raises an error it will be rescued and returned as tested object.
    def __ms__left_object
      return @left_object_value if @left_object_computed
      @left_object_computed = true
      @left_object_value = begin
        @left_proc ? @base.instance_exec(&@left_proc) : @left_object
      rescue Exception => e
        e
      end
    end

    # builds a MiniSpec failure and pass it to spec's #fail instance method.
    # using splat cause it should be able to receive `nil` and `false` as second argument
    # as well as work without second argument at all.
    def __ms__fail right_method, right_proc, *args
      right_object = right_proc ? \
        __ms__proc_definition(right_method.to_s, right_proc) : \
        (args.size > 0 ? args.first : :__ms__right_object)
      failure = {
         left_method: @left_method,
         left_object: __ms__left_object,
        right_method: (@sugar + [right_method])*' ',
        right_object: right_object,
            negation: @negation
      }
      failure[:message] = @failure_message if @failure_message
      @base.send(:fail, failure)
    end

    # reads what follow after the given method at the line where given proc is defined
    #
    # @example
    #   assure([]).has.any? {|x| x > 1}
    #   # => {|x| x > 1}
    #
    # @return   a string if proc is defined in a real file.
    #           `nil` otherwise (think of irb/pry)
    def __ms__proc_definition meth, proc
      return unless source = __ms__source_line(proc)
      source = source.split(meth)[1..-1].map(&:strip).join(meth)
      def source.inspect; self end
      source
    end

    # reads the line at which given proc is defined.
    #
    # @return   a string if file exists.
    #           `nil` if file does not exits(think of irb/pry)
    def __ms__source_line proc
      file, line = proc.source_location
      return unless lines = MiniSpec.source_location_cache(file)
      (line = lines[line - 1]) && line.strip
    end

  end
end
