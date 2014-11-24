module MiniSpec
  module InstanceAPI

    # the mock is basically a stub with difference it will also add a expectation.
    # that's it, a mock will stub a method on a object and
    # will expect that stub to be called before test finished.
    #
    # the `mock` method will return the actual stub
    # so you can build chained constraints on it.
    #
    # @note  if mocked method exists it's visibility will be kept
    #
    # @example  make `some_object` to respond to `:some_method`
    #           and expect `:some_method` to be called before current test finished.
    #           also make `:some_method` to behave differently depending on given arguments.
    #           so if called with [:a, :b] arguments it will return 'called with a, b'.
    #           called with [:x, :y] arguments it will return 'called with x, y'.
    #           called with any other arguments or without arguments at all it returns 'whatever'.
    #
    #   mock(some_object, :some_method).
    #     with(:a, :b) { 'called with a, b' }.
    #     with(:x, :y) { 'called with x, y' }.
    #     with_any { 'whatever' }
    #
    def mock object, method, visibility = nil, &proc
      if method.is_a?(Hash)
        proc && raise(ArgumentError, 'Both Hash and block given. Please use either one.')
        method.each_pair {|m,r| mock(object, m, visibility, &proc {r})}
        return MiniSpec::Mocks::HashedStub
      end
      visibility ||= MiniSpec::Utils.method_visibility(object, method) || :public
      # IMPORTANT! stub should be defined before expectation
      stub = stub(object, method, visibility, &proc)
      expect(object).to_receive(method)
      stub
    end

    # mocking multiple methods at once
    #
    # @param object
    # @param *methods
    # @param &proc
    # @return MiniSpec::Mocks::MultipleStubsProxy instance
    #
    def mocks object, *methods, &proc
      MiniSpec::Mocks::MultipleStubsProxy.new(methods.map {|m| mock(object, m, &proc)})
    end

    # same as `mock` except it will enforce public visibility on mocked method.
    def public_mock object, method, &proc
      mock(object, method, :public, &proc)
    end

    def public_mocks object, *methods, &proc
      MiniSpec::Mocks::MultipleStubsProxy.new(methods.map {|m| public_mock(object, m, &proc)})
    end

    def protected_mock object, method, &proc
      mock(object, method, :protected, &proc)
    end

    def protected_mocks object, *methods, &proc
      MiniSpec::Mocks::MultipleStubsProxy.new(methods.map {|m| mock(object, m, :protected, &proc)})
    end

    def private_mock object, method, &proc
      mock(object, method, :private, &proc)
    end

    def private_mocks object, *methods, &proc
      MiniSpec::Mocks::MultipleStubsProxy.new(methods.map {|m| mock(object, m, :private, &proc)})
    end

    # overriding given method of given object with a proxy
    # so MiniSpec can later check whether given method was called.
    #
    # if given method does not exists a NoMethodError raised
    #
    # @note  doubles and stubs will be skipped as they are already proxified
    #
    # @example
    #   proxy(obj, :a)
    #   assert(obj).received(:a)  # checking whether obj received :a message
    #
    # @param object
    # @param method_name
    def proxy object, method_name
      # do not proxify doubles
      return if object.respond_to?(:__ms__double_instance)

      # do not proxify stubs
      return if (x = @__ms__stubs__originals) && (x = x[object]) && x[method_name]

      proxies = (@__ms__proxies[object] ||= [])
      return if proxies.include?(method_name)
      proxies << method_name

      # method exists and it is a singleton.
      # `nil?` method can be overridden only through a singleton
      if method_name == :nil? || object.singleton_methods.include?(method_name)
        return __ms__mocks__define_singleton_proxy(object, method_name)
      end

      # method exists and it is not a singleton, define a regular proxy
      if visibility = MiniSpec::Utils.method_visibility(object, method_name)
        return __ms__mocks__define_regular_proxy(object, method_name, visibility)
      end

      raise(NoMethodError, '%s does not respond to %s. Can not proxify an un-existing method.' % [
        object.inspect, method_name.inspect
      ])
    end

    # replaces given method with a proxy
    # that collects received messages and calls the original method.
    #
    # @param object
    # @param method_name
    # @param visibility
    def __ms__mocks__define_regular_proxy object, method_name, visibility
      method = object.method(method_name).unbind
      method = __ms__mocks__regular_proxy(object, method_name, method)
      extender = Module.new do
        define_method(method_name, &method)
        private   method_name if visibility == :private
        protected method_name if visibility == :protected
      end
      object.extend(extender)
    end

    # defines a singleton proxy
    # that collects received messages and calls the original method.
    #
    # @param object
    # @param method_name
    def __ms__mocks__define_singleton_proxy object, method_name
      method = object.method(method_name).unbind
      method = __ms__mocks__regular_proxy(object, method_name, method)
      object.define_singleton_method(method_name, &method)
    end

    # defines a singleton proxy
    # that collects received messages and calls nothing.
    #
    # @note registering methods added this way so they can be undefined after test run
    #
    # @param object
    # @param method_name
    def __ms__mocks__define_void_proxy object, method_name
      (@__ms__stubs__originals[object] ||= {})[method_name] = []
      method = __ms__mocks__regular_proxy(object, method_name)
      object.define_singleton_method(method_name, &method)
    end

    # returns a proc to be used with `define_method`.
    # the proc will collect received messages then will call original method, if any.
    #
    # messages are stored into `@__ms__messages` Array
    # each single message looks like:
    #   {object: ..., method: ..., arguments: ..., returned: ..., raised: ..., yielded: ...}
    # `:returned` key are filled if original method called and it does not throw nor raise.
    # `:raised` key are filled if original method called and it raises an error.
    # `:yielded` key are filled if original method called with a block that was yielded.
    #
    # @param object
    # @param method_name
    # @param method [UnboundMethod]  original method, unbounded, to be called after stat collected.
    #   if `nil`, there are two scenarios:
    #   1. if method name is `:nil?` it returns `self == nil` after stat collected
    #   2. otherwise it simply returns after stat collected
    def __ms__mocks__regular_proxy object, method_name, method = nil
      method_name.is_a?(Symbol) || raise(ArgumentError, 'method name should be a Symbol')

      if :method_missing == method_name
        return __ms__mocks__method_missing_proxy(object, method)
      end
      messages = @__ms__messages
      Proc.new do |*args, &block|
        message  = {
          object:    object,
          method:    method_name,
          arguments: args,
          caller:    Array(caller)
        }
        messages.push(message)

        return self == nil if method_name == :nil?
        return unless method

        proc = block ? Proc.new do |*a,&b|
          message[:yielded] = a
          block.call(*a,&b)
        end : nil

        begin
          message[:returned] = method.bind(self).call(*args, &proc)
        rescue Exception => e
          message[:raised] = e
        end
        message.freeze
        message[:raised] ? raise(message[:raised]) : message[:returned]
      end
    end

    # replace `method_missing` method with a proxy that collects
    # received messages and calls original `method_missing` method.
    # stat are collected for two methods:
    #   1. `method_missing` itself
    #   2. method what `method_missing` received as first argument
    #
    # stat has same format as on `__ms__mocks__regular_proxy`
    # @see (#__ms__mocks__regular_proxy)
    #
    # @param object
    # @param method [UnboundMethod]  original `method_missing` method, unbounded
    def __ms__mocks__method_missing_proxy object, method
      messages = @__ms__messages
      Proc.new do |meth, *args, &block|
        message = {
          object:    object,
          method:    :method_missing,
          arguments: [meth, *args],
          caller:    Array(caller)
        }
        messages.push(message)

        message = {object: object, method: meth, arguments: args}
        messages.push(message)

        proc = block ? Proc.new do |*a,&b|
          message[:yielded] = a
          block.call(*a,&b)
        end : nil

        begin
          message[:returned] = method.bind(self).call(meth, *args, &proc)
        rescue Exception =>  e
          message[:raised] = e
        end
        message.freeze
        message[:raised] ? raise(message[:raised]) : message[:returned]
      end
    end

    # restoring stubbed methods.
    #
    # it processes `@__ms__stubs__originals` Hash where keys are the objects
    # and values are the object's methods to be restored.
    # each value is a Array where first element is the method name
    # and the second element is what previous method was.
    # - if second element is an empty Array
    #   that mean method were not defined before stubbing, so simply undefine it.
    # - if second element is a Array with last element set to :singleton Symbol,
    #   the method was a singleton before stubbing it,
    #   so defining a singleton method using second element's first element.
    # - if second element is a Array with last element set to
    #   any of :public, :protected, :private Symbol
    #   an method with according visibility will be defined
    #   using second element's first element.
    #
    # @example  there was no `x` method before stubbing
    #
    #   # => {#<Object:0x007f92bb2b52c8>=>{:x=>[]}}
    #
    # @example  `a` method was a singleton before stubbing
    #
    #   # => {#<Object:0x007f92bb2c5998>=>{:a=>[#<Method: #<Object:0x007f92bb2c5998>.a>, :singleton]}}
    #
    # @example  `a` was a public method before stubbing
    #
    #   # => {#<#<Class:0x007f92bb2cdbe8>:0x007f92bb2cd850>=>{:a=>[#<Method: #<Class:0x007f92bb2cdbe8>#a>, :public]}}
    #
    def __ms__mocks__restore_originals
      return unless stubs = @__ms__stubs__originals
      stubs.each_pair do |object, methods|
        methods.each_pair do |method_name, method|

          # clearing proxies cache so the method can be proxied again during current test
          (x = @__ms__proxies[object]) && x.delete(method_name)

          if method.last.nil?
            MiniSpec::Utils.undefine_method(object, method_name)
          elsif method.last == :singleton
            object.define_singleton_method(method_name, &method.first)
          else
            extender = Module.new do
              define_method(method_name, &method.first)
              private   method_name if method.last == :private
              protected method_name if method.last == :protected
            end
            object.extend(extender)
          end

        end
      end
      # clearing cache for cases when this run during current test
      stubs.clear
    end

    # it is critical to iterate over a "statical" copy of messages array,
    # otherwise iteration will generate a uncatchable infinite loop
    # when messages array are updated during iteration.
    def __ms__mocks__messages_copy
      @__ms__messages.dup
    end

    # takes a copy of received messages and returns
    # only messages received by given object
    #
    # @param object
    def __ms__mocks__instance_messages object
      __ms__mocks__messages_copy.select {|m| m[:object] == object}.freeze
    end

    def __ms__mocks__validate_expectations
      catch(:__ms__stop_evaluation) { @__ms__expectations.each(&:validate!) }
    end
  end
end
