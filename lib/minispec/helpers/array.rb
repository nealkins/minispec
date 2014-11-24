module Minispec

  # checks whether 2 arrays has same elements.
  # basically it is an unordered `==`
  helper :same_elements, with_context: true do |left, right, context|
    lm, rm = [left, right].map do |a|
      a.is_a?(Array) ?
        MiniSpec::Utils.array_elements_map(a) :
        raise(ArgumentError, 'Is %s an Array?' % a.inspect)
    end
    failure = '%s should %%s have same elements as %s' % [left, right].map(&:inspect)
    context[:negation] ?
      (lm == rm && fail(failure % 'NOT')) :
      (lm == rm || fail(failure % ''))
  end
  alias_helper :same_elements?,    :same_elements
  alias_helper :same_elements_as,  :same_elements
  alias_helper :same_elements_as?, :same_elements

  # checks whether given array contains ALL of given element(s).
  # if given element is a regexp, at least one element in array should match it.
  helper :contain?, with_context: true do |left, *args|
    context = args.pop
    left.is_a?(Array) || raise(ArgumentError, 'Is %s an Array?' % left.inspect)
    contain = args.all? do |a|
      a.is_a?(Regexp)?
        left.find {|b| b.to_s =~ a} :
        left.find {|b| b      == a}
    end
    failure = '%s should %%s contain %s' % [left, args].map(&:inspect)
    context[:negation] ?
      (contain && fail(failure % 'NOT')) :
      (contain || fail(failure % ''))
  end
  alias_helper :contains?, :contain?
  alias_helper :to_contain, :contain?

  # checks whether given array contains at least one of given element(s).
  # regular expressions accepted.
  helper :contain_any?, with_context: true do |left, *args|
    context = args.pop
    left.is_a?(Array) || raise(ArgumentError, 'Is %s an Array?' % left.inspect)
    contain = args.any? do |a|
      a.is_a?(Regexp)?
        left.find {|b| b.to_s =~ a} :
        left.find {|b| b      == a}
    end
    failure = '%s should %%s contain any of %s' % [left, args].map(&:inspect)
    context[:negation] ?
      (contain && fail(failure % 'NOT')) :
      (contain || fail(failure % ''))
  end
  alias_helper :contains_any?,  :contain_any?
  alias_helper :to_contain_any, :contain_any?

end
