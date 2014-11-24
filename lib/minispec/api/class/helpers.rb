module MiniSpec
  module ClassAPI

    # define custom assertion helpers.
    #
    # @note  helpers can be overridden by name,
    # that's it, if some spec inherits `:a_duck?` helper
    # you can use `helper(:a_duck?) { ... }` to override it.
    #
    # @note  tested object are passed to helper via first argument.
    #   any arguments passed to helper are sent after tested object.
    #
    # @note  if a block used on left side,
    #   it will be passed as last argument and the helper is responsible to call it.
    #   please note that block will be passed as usual argument rather than a block.
    #
    # @note  if you need the current context to be passed into helper
    #   use `:with_context` option. when doing so,
    #   the context will come as last argument.
    #
    # @example
    #
    #   describe SomeTest do
    #
    #     helper :a_pizza? do |food|
    #       does(food) =~  /cheese/
    #       does(food) =~ /olives/
    #     end
    #
    #     testing :foods do
    #       food = Cook.some_food(with: 'cheese', and: 'olives')
    #       is(food).a_pizza? #=> passed
    #
    #       food = Cook.some_food(with: 'potatoes')
    #       is(food).a_pizza? #=> failed
    #     end
    #   end
    #
    # @example any other arguments are sent after tested object
    #
    #   describe SomeTest do
    #
    #     helper :a_pizza? do |food, ingredients|
    #       does(food) =~ /dough/
    #       does(ingredients).include? 'cheese'
    #       does(ingredients).include? 'olives'
    #     end
    #
    #     testing :foods do
    #       ingredients = ['cheese', 'olives']
    #       food = Cook.some_food(ingredients)
    #       is(food).a_pizza? ingredients
    #     end
    #   end
    #
    # @example  given block passed as last argument
    #
    #    # block comes as a usual argument rather than a block
    #    helper :is_invalid do |attr, block|
    #      e = assert(&block).raise(FormulaValidationError)
    #      assert(e.attr) == attr
    #    end
    #
    #    test 'validates name' do
    #      assert(:name).is_invalid do
    #        formula "name with spaces" do
    #          url "foo"
    #          version "1.0"
    #        end
    #      end
    #    end
    #
    # @example  using `with_context` option to get context as last argument
    #
    #   describe SomeTest do
    #
    #     helper :a_pizza?, with_context: true do |subject, ingredients, context|
    #       # context is a Hash containing :left_method, left_object, :left_proc and :negation keys
    #     end
    #
    #     testing :foods do
    #       is(:smth).a_pizza? ['some', 'ingredients']
    #       # helper's context will look like:
    #       # {left_method: :is, left_object: :smth, left_proc: nil, negation: nil}
    #
    #       is { smth }.a_pizza? ['some', 'ingredients']
    #       # helper's context will look like:
    #       # {left_method: :is, left_object: nil, left_proc: 'the -> { smth } proc', negation: nil}
    #     end
    #   end
    #
    def helper helper, opts = {}, &proc
      proc || raise(ArgumentError, 'block is missing')
      helpers[helper] = [proc, opts]
    end

    def helpers
      @helpers ||= {}
    end

    def alias_helper target, source
      proc, opts = helpers[source]
      proc || raise(ArgumentError, '%s helper does not exists' % source.inspect)
      helper(target, opts, &proc)
    end

    def import_helpers base
      base.helpers.each_pair {|h,(p,o)| self.helper(h, o, &p)}
    end
    alias import_helpers_from import_helpers

    def reset_helpers
      @helpers = {}
    end
  end
end
