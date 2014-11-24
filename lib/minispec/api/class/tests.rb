module MiniSpec
  module ClassAPI

    MiniSpec::TEST_WRAPPERS.each do |verb|
      # defines test wrappers, class methods that receives test label as first argument
      # and test body as block.
      # given block will be executed inside spec instance.
      #
      # @param label
      # @param &proc
      define_method verb do |label, &proc|
        # do NOT stringify label!
        # otherwise many before/after/around hooks will broke
        tests[label] = [verb.to_s, proc]
      end
    end

    def tests
      @tests ||= {}
    end

    def import_tests base
      return if base == Minispec
      base.tests.each_pair {|l,(v,p)| self.send(v, l, &p)}
    end
    alias import_tests_from import_tests

    def reset_tests
      @tests = {}
    end

  end
end
