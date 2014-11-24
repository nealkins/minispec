module MiniSpec

  # used when some block does not raise as expected
  class ExceptionError < StandardError; end

  module Utils

    # checks whether given object is a exception of given class(if any),
    # and/or match given String/Regexp(if any)
    #
    # if no args given any raised exception accepted.
    # if a class given it checks whether raised exception is of given type.
    # if a string or regexp given it checks whether raised message matches it.
    #
    # @param subject potentially a Exception instance
    # @param [Hash]  context
    # @param [Array] *args  actual expectations. can be a Class, String or Regexp
    # @return [ExceptionError] if not raised as expected
    #         [true]           if raised an exception that meets expectations
    #
    def exception_raised? subject, context, *args
      if context[:right_proc]
        args.any? && raise(ArgumentError, 'Both arguments and block given. Please use either one.')
        return MiniSpec::ExceptionInspector.raised_as_expected_by_proc?(subject, context)
      end

      type, match = nil
      args.each { |a| a.is_a?(Class) ? type = a : match = a }
      regexp = match.is_a?(Regexp) ? match : /^#{Regexp.escape(match.to_s)}\z/

      context = {negation: context[:negation]} # it is critical to not alter received context
      if context[:is_a_exception]         = subject.is_a?(Exception)
        context[:valid_exception_type]    = type  ? (subject.class == type)  : nil
        context[:valid_exception_message] = match ? (subject.to_s =~ regexp) : nil
      end

      MiniSpec::ExceptionInspector.raised_as_expected?(subject, type, match, context)
    end
  end

  module ExceptionInspector
    extend MiniSpec::Utils
    extend self

    def raised_as_expected_by_proc? subject, context
      x = context[:right_proc].call(*subject) # splat needed on multiple expectations
      if context[:negation]
        # return true if block returns false or nil
        return true if !x
        return ExceptionError.new('Not expected any error to be raised')
      end
      # return true if block returns a positive value
      return true if x
      ExceptionError.new('Expected some error to be raised')
    end

    def raised_as_expected? subject, type, match, context
      if type && match
        x = validate_type(subject, type, context)
        return x if x.is_a?(ExceptionError)
        validate_message(subject, match, context)
      elsif type
        validate_type(subject, type, context)
      elsif match
        validate_message(subject, match, context)
      else
        validate(context)
      end
    end

    def validate context
      x = context[:is_a_exception]
      if context[:negation]
        # return true if no exception raised
        return true if !x
        # return ExceptionError cause a exception raised but not expected
        return ExceptionError.new('Not expected a error to be raised')
      end
      # return true if some exception raised
      return true if x
      # return ExceptionError cause no exception raised
      ExceptionError.new('Expected some error to be raised')
    end

    def validate_type subject, type, context
      x = context[:valid_exception_type]
      if context[:negation]
        # return true if raised exception is not of expected type OR no exception raised et all
        return true if !x
        # return ExceptionError cause exception should NOT be of given type
        return ExceptionError.new("Not expected a %s error to be raised." % pp(type))
      end
      # return true if raised exception is of expected type
      return true if x
      # return ExceptionError cause raised exception is NOT of given type OR no exception raised et all
      ExceptionError.new("Expected a %s error to be raised.\nInstead %s" % [
        pp(type),
        context[:is_a_exception] ?
          'a %s error raised' % pp(subject.class) :
          'nothing raised'
      ])
    end

    def validate_message subject, match, context
      x = context[:valid_exception_message]
      if context[:negation]
        # return true if exception message does not match expected value OR no exception raised et all
        return true if !x
        # return ExceptionError cause exception message should NOT match given value
        return ExceptionError.new('Not expected raised error to match %s' % pp(match))
      end
      # return true if exception message matched expected value
      return true if x
      # return ExceptionError cause exception message does NOT match given value OR no exception raised et all
      ExceptionError.new("Expected a error that match %s to be raised.\nInstead %s." % [
        pp(match),
        context[:is_a_exception] ?
          'a error with following message raised: %s' % pp(subject) :
          'nothing raised'
      ])
    end
  end
end
