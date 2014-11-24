module Minispec

  # a shortcut for `assert(something) == true`
  # passes only if `subject == true`
  #
  # @example
  #   describe do
  #     let(:something) { true }
  #
  #     test :something do
  #       is(something).true?
  #     end
  #   end
  helper :true?, with_context: true do |left_object,context|
    value, message = if left_object.is_a?(Proc)
      returned = self.instance_exec(&left_object)
      [
        returned,
        proc {'expected block at "%s" to return true, instead it returned %s' % [
          MiniSpec::Utils.source(left_object),
          returned.inspect
        ]}
      ]
    else
      [left_object, proc {'expected %s to be true' % left_object.inspect}]
    end
    context[:negation] ?
      (value == true && fail('Not ' + message.call)) :
      (value == true || fail(message.call.capitalize))
  end
  alias_helper :is_true, :true?

  # passes if subject is not nil nor false
  helper :positive, with_context: true do |left_object,context|
    value, message = if left_object.is_a?(Proc)
      returned = self.instance_exec(&left_object)
      [
        returned,
        proc {'expected block at "%s" to return a non falsy value, instead it returned %s' % [
          MiniSpec::Utils.source(left_object),
          returned.inspect
        ]}
      ]
    else
      [
        left_object,
        proc{'expected %s to be non falsy' % left_object.inspect}
      ]
    end
    context[:negation] ?
      (value && fail('Not ' + message.call)) :
      (value || fail(message.call.capitalize))
  end
  alias_helper :positive?,   :positive
  alias_helper :is_positive, :positive
  alias_helper :truthful?,   :positive
  alias_helper :non_falsy?,  :positive

  # a shortcut for `assert(something) == false`
  # passes only if `subject == false`
  helper :false?, with_context: true do |left_object,context|
    value, message = if left_object.is_a?(Proc)
      returned = self.instance_exec(&left_object)
      [
        returned,
        proc {'expected block at "%s" to return false, instead it returned %s' % [
          MiniSpec::Utils.source(left_object),
          returned.inspect
        ]}
      ]
    else
        [
          left_object,
          proc{'expected %s to be false' % left_object.inspect}
        ]
    end
    context[:negation] ?
      (value == false && fail('Not ' + message.call)) :
      (value == false || fail(message.call.capitalize))
  end
  alias_helper :is_false, :false?

  # passes if subject is nil or false
  helper :negative, with_context: true do |left_object,context|
    value, message = if left_object.is_a?(Proc)
      returned = self.instance_exec(&left_object)
      [
        returned,
        proc {'expected block at "%s" to return a falsy value, instead it returned %s' % [
          MiniSpec::Utils.source(left_object),
          returned.inspect
        ]}
      ]
    else
      [
        left_object,
        proc {'expected %s to be falsy' % left_object.inspect}
      ]
    end
    context[:negation] ?
      (value || fail('Not ' + message.call)) :
      (value && fail(message.call.capitalize))
  end
  alias_helper :negative?, :negative
  alias_helper :falsy?,    :negative
  alias_helper :is_falsy,  :negative

end
