module MiniSpec
  module ClassAPI

    # run some code before any or matching tests.
    # if called without arguments the hook will run before any test.
    # if any arguments passed it will run only before matched tests.
    # strings, symbols and regexps accepted as arguments.
    # also :except option accepted.
    #
    # @example callback to run before any test
    #   describe SomeTest do
    #
    #     before do
    #       # ...
    #     end
    #   end
    #
    # @example callback to run only before :cart test
    #   describe Specs do
    #
    #     before :cart do
    #       # ...
    #     end
    #
    #     testing :cart do
    #       # ...
    #     end
    #   end
    #
    # @example callback to run before any test that match /cart/
    #   describe Specs do
    #
    #     before /cart/ do
    #       # ...
    #     end
    #
    #     testing :cart do
    #       # ...
    #     end
    #   end
    #
    # @example callback to run before any test that match /cart/ except :load_cart
    #   describe Specs do
    #
    #     before /cart/, except: :load_cart do
    #       # ...
    #     end
    #
    #   end
    #
    # @example callback to run before any test that match /shoes/
    #           but ones that match /red/
    #   describe Specs do
    #
    #     before /shoes/, except: /red/ do
    #       # ...
    #     end
    #
    #   end
    #
    def before *matchers, &proc
      proc || raise(ArgumentError, 'block is missing')
      matchers.flatten!
      matchers = [:*] if matchers.empty?
      return if before?.find {|x| x[0] == matchers && x[1].source_location == proc.source_location}
      before?.push([matchers, proc])
    end

    def before? filter = nil
      hooks_filter(@before ||= [], filter)
    end

    def reset_before
      @before = []
    end

    # import `:before` and `:before_all` hooks from base
    def import_before base
      import_instance_variable(:before_all, base)
      base.before?.each {|(m,p)| self.before(m, &p)}
    end
    alias import_before_from import_before

    # code to run once at spec initialization, just before start running tests.
    # this callback will run only once - at spec initialization.
    # for callbacks that runs before any test @see #before
    def before_all &proc
      proc || raise(ArgumentError, 'block is missing')
      @before_all = proc
    end
    alias before! before_all

    def before_all?
      @before_all
    end

    def reset_before_all
      remove_instance_variable(:@before_all)
    end
  end
end
