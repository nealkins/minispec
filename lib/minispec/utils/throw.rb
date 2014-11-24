module MiniSpec

  class ThrowError < StandardError; end

  module Utils

    # checks whether given block throws a symbol
    # and if yes compare it with expected one.
    # if a optional value given it will be compared to thrown one.
    #
    # @param expected_symbol
    # @param expected_value
    # @param [Proc] &proc
    # @return a failure [ThrowError] if expectation not met.
    #         true if expectations met.
    #
    def symbol_thrown? expected_symbol, expected_value, context, &block
      thrown_symbol, thrown_value = catch_symbol(expected_symbol, &block)

      if context[:right_proc]
        expected_symbol && raise(ArgumentError, 'Both arguments and block given. Please use either one.')
        return MiniSpec::ThrowInspector.thrown_as_expected_by_proc?(thrown_symbol, context)
      end

      MiniSpec::ThrowInspector.thrown_as_expected?(expected_symbol, expected_value, thrown_symbol, thrown_value, context)
    end

    # calling given block and catching thrown symbol, if any.
    #
    # @param expected_symbol
    # @param [Proc] &block
    #
    def catch_symbol expected_symbol, &block
      thrown_symbol, thrown_value = nil
      begin
        if expected_symbol
          thrown_value = catch :__ms__nothing_thrown do
            catch expected_symbol do
              block.call
              throw :__ms__nothing_thrown, :__ms__nothing_thrown
            end
          end
          thrown_symbol = expected_symbol unless thrown_value == :__ms__nothing_thrown
        else
          block.call
        end
      rescue => e
        raise(e) unless thrown_symbol = extract_thrown_symbol(e)
      end
      [thrown_symbol, thrown_value]
    end

    # extract thrown symbol from given exception
    #
    # @param exception
    #
    def extract_thrown_symbol exception
      return unless exception.is_a?(Exception)
      return unless s = exception.message.scan(/uncaught throw\W+(\w+)/).flatten[0]
      s.to_sym
    end
  end

  module ThrowInspector
    extend MiniSpec::Utils
    extend self

    def thrown_as_expected_by_proc? thrown_symbol, context
      x = context[:right_proc].call(*thrown_symbol) # splat needed on multiple expectations
      if context[:negation]
        return true if !x
        return ThrowError.new('Not expected any symbol to be thrown')
      end
      return true if x
      ThrowError.new('Expected a symbol to be thrown')
    end

    def thrown_as_expected? expected_symbol, expected_value, thrown_symbol, thrown_value, context
      if expected_symbol && expected_value
        x = correct_symbol_thrown?(expected_symbol, thrown_symbol, context)
        return x if x.is_a?(ThrowError)
        correct_value_thrown?(expected_symbol, expected_value, thrown_value, context)
      elsif expected_symbol
        correct_symbol_thrown?(expected_symbol, thrown_symbol, context)
      else
        any_symbol_thrown?(thrown_symbol, context)
      end
    end

    def any_symbol_thrown? thrown_symbol, context
      if context[:negation]
        return true if !thrown_symbol
        return ThrowError.new('%s symbol thrown when not expected' % pp(thrown_symbol))
      end
      return true if thrown_symbol
      ThrowError.new('Expected a symbol to be thrown')
    end

    def correct_symbol_thrown? expected_symbol, thrown_symbol, context
      # needed here cause this method are invoked directly by mock validators.
      # and it's not a double check cause Utils.symbol_thrown?
      # wont arrive here if called with a block
      if context[:right_proc]
        return thrown_as_expected_by_proc?(thrown_symbol, context)
      end

      x = expected_symbol == thrown_symbol
      if context[:negation]
        return true if !x
        return ThrowError.new('Not expected %s symbol to be thrown' % pp(thrown_symbol))
      end
      return true if x
      ThrowError.new('Expected %s symbol to be thrown. Instead %s thrown.' % [
        pp(expected_symbol),
        thrown_symbol ?
          pp(thrown_symbol) :
          'nothing'
      ])
    end

    def correct_value_thrown? thrown_symbol, expected_value, thrown_value, context
      x = expected_value.is_a?(Regexp)   ?
        (thrown_value.to_s =~ expected_value) :
        (thrown_value      == expected_value)
      if context[:negation]
        return true if !x
        return ThrowError.new('Not expected %s symbol\'s value to match %s' % [
          thrown_symbol,
          thrown_value,
        ].map(&method(:pp)))
      end
      return true if x
      ThrowError.new("Expected %s symbol's value to match %s\nActual value: %s" % [
        thrown_symbol,
        expected_value,
        thrown_value
      ].map(&method(:pp)))
    end
  end
end
