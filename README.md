
### Minispec

**Simple, Intuitive, Full-featured Testing Framework**

[Install](#install) |
[Quick Start](#quick-start) |
[Docs](#docs) |
[Contributors](#contributors) |
[Authors and License](#license)

## What and Why

Simply i tired of syntax like `assert_equal(b, a)`, `a.should == b` and `expect(a).to eq(b)` etc.

`is(a) == b` is all i want to type.

Also i tired to learn framework specific techniques. I want simply to use Ruby's native methods:

```ruby
is(a) == b
does(a).include?(b)
is(a).empty?
```

`==`, `include?`, `empty?` are all Ruby methods called on `a`.

What you see around `a` is a simple wrapper that passes messages to `a` and mark the assertion as passed or failed, depending on returned value.


## Install

Add this line to your application's Gemfile:

```ruby
gem 'minispec'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install minispec
```

then load it using `require 'minispec'`


## Quick Start

*Examples borrowed from [github.com/rubyspec](https://github.com/rubyspec/rubyspec). Commented are the original assertions.*

```ruby
describe "Array.allocate" do
  it "returns an instance of Array" do
    ary = Array.allocate
    # ary.should be_an_instance_of(Array)
    is(ary).instance_of?(Array)
  end

  it "returns a fully-formed instance of Array" do
    ary = Array.allocate
    # ary.size.should == 0
    assert(ary.size) == 0
    ary << 1
    # ary.should == [1]
    assert(ary) == [1]
  end

  it "does not accept any arguments" do
    # lambda { Array.allocate(1) }.should raise_error(ArgumentError)
    does { Array.allocate(1) }.raise?(ArgumentError)
  end
end
```


# Docs

  * [Defining Specs](#defining-specs)
    * [Nested Specs](#-nested-specs)
  * [Defining Tests](#defining-tests)
    * [Skipping a test](#-skipping-a-test)
    * [Mark a test as failed](#-mark-a-test-as-failed)
  * [Shared examples and setups](#shared-examples-and-setups)
    * [Resetting included resources](#-resetting-included-resources)
  * [Local variables and subject](#local-variables-and-subject)
  * [Custom error messages](#custom-error-messages)
  * [Hooks](#hooks)
    * [`before` and `before_all`](#-before-and-before_all)
    * [`after` and `after_all`](#-after-and-after_all)
    * [`around` and `around_all`](#-around-and-around_all)
    * [Filters](#-filters)
  * [Assertions](#assertions)
    * [Negative assertions](#-negative-assertions)
    * [Semantic sugar](#-semantic-sugar)
  * [Helpers](#helpers)
    * [Built-in helpers](#-built-in-helpers)
      * [raise](#-raise-helper)
      * [throw](#-throw-helper)
      * [boolean](#-boolean-helpers)
      * [array](#-array-helpers)
      * [silent](#-silent-helper)
    * [Custom helpers](#-custom-helpers)
    * [Helpers with blocks](#-helpers-with-blocks)
    * [Helpers aliases](#-helpers-aliases)
  * [Mocking](#mocking)
    * [Expectations](#-expectations)
      * [Constraints](#-constraints)
        * [arguments](#-arguments)
        * [returned value](#-returned-value)
        * [raised exception](#-raised-exception)
        * [thrown symbol](#-thrown-symbol)
        * [yielded arguments](#-yielded-arguments)
        * [messages amount](#-messages-amount)
        * [messages order](#-messages-order)
    * [Spies](#spies)
    * [Stubs](#stubs)
      * [Argument-vary stubs](#-argument-vary-stubs)
      * [Stubbing multiple methods at once](#-stubbing-multiple-methods-at-once)
      * [Chained stubs](#-chained-stubs)
      * [Calling original](#-calling-original)
      * [Stubs visibility](#-stubs-visibility)
    * [Mocks](#mocks)
    * [Doubles](#doubles)
  * [Running Specs](#running-specs)


## Defining Specs

There are 2 ways to define Minispec specs: by using Minispec's DSL and by using Ruby classes.

Minispec's DSL has 3 methods that allow to define specs:

  * `describe`
  * `context`
  * `section`

They accepts a single argument(the spec name) and a block containing setups and tests:

```ruby
describe SomeClass do
  # setups and tests
end
```

When using classes you should `include Minispec`:

```ruby
class SomeSpec
  include Minispec
  # setups and tests
end
```

[&#8679; Table of Contents](#docs)


### &#8627; Nested Specs

Minispec allows to define unlimitedly nested specs using same `describe`/`context`/`section` DSL:

Nested specs are akin of valve, they inherits everything(except tests) from parent spec but share nothing with it and does not change parent state in any way:

```ruby
describe :A do
  before { @letter = 'A' }

  # some tests

  describe :B do
    before { @letter = 'B' }
    # it will run both inherited and own callbacks but wont change A's @letter
  end

  # @letter is still 'A'
end
```


[&#8679; Table of Contents](#docs)


## Defining Tests

Here are the methods that can be used to define tests:

  * `test`
  * `testing`
  * `example`
  * `should`
  * `it`


```ruby
# spec
describe :RequestTest do

  # test 1
  should 'respond to #user_agent' do
    request = Sinatra::Request.new({'HTTP_USER_AGENT' => 'Test'})
    does(request).respond_to?(:user_agent)
    assert(request.user_agent) == 'Test'
  end

  # test 2
  it 'is secure when the url scheme is https' do
    request = Sinatra::Request.new('rack.url_scheme' => 'https')
    is(request).secure?
  end

  # test 3
  testing 'it respects X-Forwarded-Proto header for proxied SSL' do
    request = Sinatra::Request.new('HTTP_X_FORWARDED_PROTO' => 'https')
    is(request).secure?
  end

  # test 4
  it "exposes the preferred type's parameters" do
    request = Sinatra::Request.new('HTTP_ACCEPT' => 'image/jpeg; compress=0.2')
    assert(request.preferred_type.params) == { 'compress' => '0.2' }
  end

  # etc.
end
```

Tests can Not be defined inside another tests. If you need concerns separation use nested specs instead.

[&#8679; Table of Contents](#docs)


### &#8627; Skipping a test

When you need to skip some test simply use `skip` method inside test:

```ruby
should 'work with new Hash syntax' do
  skip if RUBY_VERSION < '1.9'
  # code here wont be evaluated on Ruby 1.8
end
```

Any code after `skip` method will be just ignored and test reported as skipped.


[&#8679; Table of Contents](#docs)


### &#8627; Mark a test as failed

When you need a custom failure message use `fail` method:

```ruby
# will generate standard failure message
assert(1) == 2

# using custom failure message
1 == 2 || fail('expected 1 to be equal to 2 :(')
```

Assertions that comes after a failure will be ignored.

If you need all assertions to be evaluated regardless failures use `continue_on_failures(true)` at spec level(not inside test).


[&#8679; Table of Contents](#docs)


## Shared examples and setups

Often you need to share some setups and tests(a.k.a examples) between various specs.

To define shared setups/examples simply define a module that includes `Minispec`.

Later that module can be included into any spec.

```ruby
module MailboxAssets
  include Minispec

  before { @mailbox = Mailbox.new }

  test '#deliver' do
    # ...
  end
end

describe :SMTP do
  include MailboxAssets
  
  before do
    # will run included hooks before ones defined here,
    # so @mailbox is available here
    @mailbox.transport = :smtp
  end

  # will set @mailbox's transport to :smtp and run #deliver test
end

describe :sendmail do
  include MailboxAssets

  before { @mailbox.transport = :sendmail }
  # will set @mailbox's transport to :sendmail and run #deliver test
end
```


[&#8679; Table of Contents](#docs)


### &#8627; Resetting included resources

Minispec will include following resources from base module:

  * `:tests`
  * `:helpers`
  * `:before`
  * `:after`
  * `:around`
  * `:vars`
  * `:continue_on_failures`

If you need to reset any of included resource, use `reset` method with resources to reset:

```ruby
module CPUExamples do
  # some setups and tests
end

describe :MacBook do
  include CPUExamples
  
  reset :before # resets :before hooks
  reset :before, :after # resets :before and :after hooks
  # etc

end
```


[&#8679; Table of Contents](#docs)


## Local variables and subject

Minispec provides `let` method as a clean way to define local variables. Its block are executed only once per test, when given variable used for first time.

```ruby
describe Array do
  let(:array) { Array.new }

  it 'is a Enumerable' do
    assert(array).is_a? Enumerable
  end
end
```

`subject` allow to test some object without repeatedly typing it. It is automatically set when a spec defined using Minispec's DSL:

```ruby
describe Hash do
  it 'responds to :[]' do
    assert.respond_to? :[]
  end
end
```

In example above the subject are automatically set to `Hash` and automatically picked up by `assert`.

It can also be written as `assert(subject).respond_to? :[]` or  even `assert(Hash).respond_to? :[]`, in case you prefer more explicit assertions.

[&#8679; Table of Contents](#docs)


## Custom error messages

Minispec will do its best to provide detailed failure messages.

However there are cases when you need to use custom messages.

This is easily done by providing your error message as second argument,
using `:on_error` key:

```ruby
assert(pizza, on_error: "Seems not enough olives...").is_tasty
```

Now if pizza is not tasty enough, Minispec will inform us about the lack of olives rather than just generally complain about poor taste.


[&#8679; Table of Contents](#docs)


## Hooks

### &#8627; `before` and `before_all`

`before` callback runs before each test:

```ruby
describe Array do
  before { @array = subject.new }
  # @array will be different for each test
end
```

**Important:** `before` callbacks are incremental, meant that all callbacks, inherited and defined, will be called.

First will be called inherited callbacks. Defined ones will run second:

```ruby
describe :A do
  before { @letter = 'A' }

  context :a do
    before { @letter.downcase! }
    # two callbacks will run here:
    #   1. @letter = 'A'
    #   2. @letter.downcase!
  end

  # @letter is still 'A' cause child specs does not change parent's state
end
```


**`before_all`** will run only once, at spec initialization, before any test run:

```ruby
describe Array do
  before_all { @array = subject.new }
  # @array will be the same for all tests
end
```

**Important:** Unlike `before` callbacks, `before_all` ones **are not incremental**, so only the last defined/inherited callback will be called.

### &#8627; `after` and `after_all`

`after` will run after each test, regardless was it passed or failed.

**Important:** Just like `before` callbacks, `after` ones are incremental, so all callbacks, inherited and defined, will run in appropriate order - first inherited then defined.

**`after_all`** will run only once, after all tests finished. It will run regardless tests status.

**Important:** Unlike `after` callbacks, `after_all` ones **are not incremental**, so only the last defined/inherited callback will be called.

### &#8627; `around` and `around_all`

Allow to run tests inside a predefined wrapper.

The block will receive the test as first argument and should call `#run` on it:

```ruby
describe ActorSystem do
  around do |test|
    Celluloid::ActorSystem.new.within do
      test.run
    end
  end
  # each test will run within own ActorSystem
end
```

**Important:** Unlike `before`/`after` callbacks, `around` are not incremental, meant that only the last callback will be called regardless how many callbacks was inherited/defined.

`around_all` is similar to `around` except it will run all tests inside given block.

It will receive the spec as first argument and should call `run` on it:

```ruby
require 'tmpdir'

describe :FileManager do
  around_all do |spec|
    # running all tests into a temporary folder
    Dir.mktmpdir do
      spec.run
    end
  end
end
```


[&#8679; Table of Contents](#docs)

### &#8627; Filters

When you need a callback to run only before/after/around specific test(s), pass that tests names as arguments.

*Run only before `:a` and `:b` tests*:

```ruby
before :a, :b do
  # ...
end
```

It is also possible to use `:except` option.

*Run after all except `:x`*:

```ruby
after except: :x do
  # ...
end
```

And to make matchers even more useful, test names can be provided as regular expressions.

*Run around tests that match `/a/`*:

```ruby
around /a/ do
  # ...
end
```

*Run before tests that match `/a/` but not before `:abc`*:

```ruby
before /a/, except: :abc do
  # ...
end
```


*Run before tests that match `/a/` but not before ones that match `/ab/`*:

```ruby
before /a/, except: /ab/ do
  # ...
end
```



[&#8679; Table of Contents](#docs)


## Assertions

Minispec's assertions mechanism is pretty simple: tested objects are wrapped into a proxy that intercepts messages, sending them to tested object and mark assertion as passed or failed based on returned value.

There are plenty of wrappers used in Minispec. `assert` and `expect` are only few of them:

```ruby
assert(a) == b
expect(a).include?(b)
assert(a).nil?
# etc.
```

Though these assertions looks mostly ok, they are not truly semantic.<br>
Let's use some more wrappers:

```ruby
is(a) == b
does(a).include?(b)
is(a).nil?
# etc.
```

Here is the list of available wrappers:

  * `assert`
  * `affirm`
  * `assume`
  * `assure`
  * `expect`
  * `verify`
  * `check`
  * `prove`
  * `would`
  * `will`
  * `is`
  * `is?`
  * `are`
  * `are?`
  * `was`
  * `was?`
  * `does`
  * `does?`
  * `did`
  * `did?`
  * `have`
  * `have?`
  * `has`
  * `has?`

[&#8679; Table of Contents](#docs)


### &#8627; Negative assertions

There are two kind of negations in Minispec:

  * negative wrappers
  * post-wrapper negations

List of negative wrappers:

  * `refute`
  * `negate`
  * `fail_if`
  * `not_expected`
  * `assert_not`

```ruby
refute(a) == b
fail_if(a).include?(b)
# etc.
```

List of post-wrapper negations:

  * `not`
  * `has_not`
  * `have_not`
  * `does_not`
  * `did_not`
  * `is_not`
  * `is_not_a`
  * `wont`

```ruby
assert(a).not == b
assert(a).does_not.include?(b)
assert(a).is_not.nil?
# etc.
```

[&#8679; Table of Contents](#docs)


### &#8627; Semantic sugar

Just like post-wrapper negations, sugar methods are used after a wrapper and are aimed to add some more semantic sense to assertions.

List of semantic sugar methods:

  * `a`
  * `is`
  * `is_a`
  * `are`
  * `will`
  * `was`
  * `does`
  * `did`
  * `have`
  * `has`
  * `to`
  * `be`
  * `been`

```ruby
is(x).a.instance_of?(Y)
assert(a).is.nil?
expect(x).was.called?
assert(x).has.been.locked?
expect(a).to.include?(b)
expect(a).to.be.empty?
expect(x).to.have.children
# etc.
```

[&#8679; Table of Contents](#docs)


## Helpers

In most cases native Ruby methods are enough for some basic testing.<br>
However some basic testing is never enough for code that matters.

Minispec's helpers system allows to write tests of any complexity without sacrifice simplicity and semantic readability.

The idea is simple: if the wrapper detects a helper with same name as received message, it will will pass that message to the helper rather than to the tested object.

Helper is receiving tested object as first argument and can apply any assertions on it.

It does not mater what a helper returns. If some assertion fails inside a helper, the test that calls the helper will be marked as failed and failure will contain both test and helper's locations.

*`blank?` helper not defined, so `blank?` message are passed to `a`. If `a` does not respond to `blank?`, a `NoMethodError` will be raised*:

```ruby
is(a).blank?
```

*`blank?` helper defined, so `blank?` message are passed to helper rather than to `a`. `a` may or may not respond to `blank?`*:

```ruby
# defining a helper
helper :blank? do |a|
  # validating given object
  is(a.to_s).empty?
end

# defining a test
should 'return a non-empty string' do
  a = Some.abstract.string
  is(a).blank?
end
```

[&#8679; Table of Contents](#docs)

### &#8627; Built-in helpers

Minispec comes with some built-in helpers for most common scenarios: raised exceptions, thrown symbols, booleans etc.

#### &#8627; `raise` helper


*Without arguments any exception will be accepted*:

```ruby
does { some risky code }.raise

# can also be written as
does { some risky code }.raise?
does { some risky code }.raise_error?
expect { some risky code }.to_raise
expect { some risky code }.to_raise_error
```

*When given a class it will accept only exceptions of given class*:

```ruby
expect { some risky code }.to_raise NoMethodError
```

*When given a string only exceptions with same message will be accepted*:

```ruby
expect { some risky code }.to_raise 'some error message'
```

*When given a Regexp only exceptions with same message as given string will be accepted*:

```ruby
expect { some risky code }.to_raise /some error message/
```

*When both class and String/Regexp given, it will accept only exceptions of given class that equals/match given String/Regexp*:

```ruby
expect { some risky code }.to_raise NoMethodError, 'some error message'
expect { some risky code }.to_raise NoMethodError, /some error message/
```

**When you need even more control over raised exception, use a block.**

*Expect any error to be raised except LoadError:*

```ruby
expect { something }.to_raise {|e| e.is_a?(Exception) && e.class != LoadError}
```

*Expect raised error backtrace to contain a specific line:*

```ruby
expect { something }.to_raise {|e| e.backtrace.find {|l| l =~ /something/} }
```

[&#8679; Table of Contents](#docs)

#### &#8627; `throw` helper

*When called without arguments any thrown symbol accepted*:

```ruby
does { some code }.throw

# can also be written as
does { some code }.throw?
does { some code }.throw_symbol?
expect { some code }.to_throw
expect { some code }.to_throw_symbol
```

*When called with a symbol it will pass only if given symbol thrown*:

```ruby
expect { some code }.to_throw :some_symbol
```

*When called with a symbol and a value it will pass only if given symbol thrown with given value*:

```ruby
expect { some code }.to_throw :some_symbol, 'some value'
```

**Also a block can be used to validate thrown symbol.**<br>
**Important:** when a block used, only thrown symbol passed to block, so no way to validate the value by block.

*Expect any symbol to be thrown except `:halt`*

```ruby
does { some code }.throw? {|s| s != :halt}
```

**Limitations:** the code to be inspected for thrown symbols should run out of its `catch` block.

*This test wont pass cause thrown symbol are caught early:*

```ruby
describe User do

  def create_account *args
    catch :invalid_email do
      User.new *args
    end
  end

  it 'fails if invalid email given' do
    expect { create_account(email: 'blah') }.to_throw :invalid_email
  end
end
```

For this to work you should run `User.new` outside `catch` block.

[&#8679; Table of Contents](#docs)


#### &#8627; Boolean helpers

*`true?`: expects tested object to be `true`*:

```ruby
is(a).true?
assert(a).is.true?

# same as
assert(a) == true
```

*`false?`: expects tested object to be `false`*:

```ruby
is(a).false?
assert(a).is.false?

# same as
assert(a) == false
```

*`positive`, `positive?`, `truthful?, `non_falsy?`: expects tested object to not be `nil` nor `false`*:

```ruby
is(a).positive?
is(a).truthful?
expect(a).is.positive
expect(a).is.non_falsy?
```


[&#8679; Table of Contents](#docs)

#### &#8627; `silent` helper

`silent` (aliased as `silent?` and `is_silent`) expects given block to output nothing, that's it, the block should  write nothing to STDOUT nor to STDERR.

```ruby
is { some_code_here }.silent?
```

or

```ruby
assert do
  some
  more
  code
  here
end.is_silent
```


[&#8679; Table of Contents](#docs)


#### &#8627; `Array` helpers

*`same_elements`: expects tested object is an array that have same elements as given array*:

```ruby
a = [1, 2, :x]
b = [:x, 1, 2]
expect(a).has.same_elements_as(b)
# => passed
```

*`contain`: expects tested object is an array that contains given elements. Order does not matter*:

```ruby
a = [1, 2, :x]
does(a).contain? :x, 2
# => passed
does(a).contain? :y, 2
# => failed
```

[&#8679; Table of Contents](#docs)


### &#8627; Custom helpers

The power of Minispec's helpers are revealed in full only when you define your own helpers. It is simply done by using `helper` method with a block. The block will receive tested object as first argument and you can test it to the backbone:

```ruby
describe Cooking do
  helper :looks_like_a_pizza? do |food|
    assert(food).contains? :olives, :cheese
  end

  it 'cooks a pizza' do
    food = Cook.new.pizza
    does(food).looks_like_a_pizza?
  end
end
```

When you pass some arguments into helper they comes after tested object:

```ruby
helper :ok_with_body? do |response, body|
  assert(response.status) == 200
  assert(response.body) ==  body
end

test 'index action' do
  get '/'
  is(last_response).ok_with_body? 'index'
end
```

[&#8679; Table of Contents](#docs)


### &#8627; Helpers with blocks

If object passed within a block, the helper will receive that block as first argument.

Please note that the block will be received as usual argument rather than a block.

```ruby
helper :blank? do |block|
  is(block.call).empty?
  # or is(&block).empty?
end

should 'pass' do
  is { '' }.blank?
end
```

When a helper used with a block, the block will be passed as last argument,
in form of a simple argument rather than a block:

```ruby
helper :any_of? do |arr, block|
  assert(arr).any?(&block)
end

should 'pass' do
  has([1, 2]).any_of? {|v| v > 1}
end
```

[&#8679; Table of Contents](#docs)


### &#8627; Helpers aliases

Often you need some helper to be accessed by various names.<br>
Minispec allows to create helper aliases by using `alias_helper` method.<br>
Simply pass new name as first argument and existing helper name as second:

```ruby
helper :open? do |door|
  # ...
end
alias_helper :not_closed, :open?

it 'creates a open door' do
  door = Door.new(open: true)
  is(door).open?
end

it 'opens door with open!' do
  door = Door.new
  door.open!
  assert(door).not_closed
end
```


[&#8679; Table of Contents](#docs)


## Mocking

Minispec comes with a pretty full set of mocking instruments.

Though there are obvious differences, these instruments are kind of similar to ones used in another libraries like [mocha](https://github.com/freerange/mocha), [rr](https://github.com/rr/rr) and [rspec-mocks](https://github.com/rspec/rspec-mocks).

Perhaps sometimes verbose, they gives you full control over mocked objects.


### &#8627; Expectations

Useful when you expect some object to receive some message(s).

Expectations are validated after current test evaluation finished. So the object are expected to receive given message(s) somewhere in the near future, just before current test ends.

Use `to_receive` helper to add an expectation.

*Expect bob to eat an apple:*

```ruby
apple = Apple.new
bob = Kid.new
bob.bag << apple
expect(apple).to_receive(:eaten)
```

[&#8679; Table of Contents](#docs)


**&#8627; Expecting multiple messages**

Often you need to expect multiple messages on a object.

You could of course add a expectation for each message:

```ruby
expect(a).to_receive :x
expect(a).to_receive :y
```

but this is tedious and becomes hairy very quickly.

Recommended approach is to use `:to_receive` helper with multiple arguments:

```ruby
expect(a).to_receive(:x, :y)
```

Much better, huh?

**&#8627; Assert given message(s) never received**

*Ensure `a` wont receive `:b` message:*

```ruby
expect(a).to_not.receive(:b)
```

*same:*

```ruby
refute(a).receive(:b)
```

*Ensure `a` wont receive `:x` message nor `:y`:*

```ruby
assert(a).wont.receive(:x, :y)
```

if at least one of messages received, the test will fail.

[&#8679; Table of Contents](#docs)


### &#8627; Constraints

 Sometimes just checking that some messages are received is not enough. We need to know whether certain message received with certain arguments and returned/raised/thrown certain value.

 Minispec allows to add such kind of constraints with ease.


#### &#8627; Arguments

*Expect `a` to receive `:b` message with x, y arguments:*

```ruby
expect(a).to_receive(:b).with('x', 'y')
```

*Expect `a` to receive `:b` message with whatever arguments:*

```ruby
expect(a).to_receive(:b).with {|*| true}
```

*Expect `a` to receive `:b` message with exactly 2 arguments, whatever they are:*

```ruby
expect(a).to_receive(:b).with {|*a| a.size == 2}
```

*Expect at least 2 arguments and second one to be bigger than first:*

```ruby
expect(a).to_receive(:b).with {|x,y| y > x}
```

*Expect exactly 2 arguments and second one to be bigger than first:*

```ruby
expect(a).to_receive(:b).with do |*a|
  assert(a.size) == 2
  is(a.last) > a.first
end
```

Another way is to just return `true` or `false`. If block returns true, the test will pass.

```ruby
expect(a).to_receive(:b).with {|*a| a.size == 2 && a.last > a.first}
```


**&#8627; Arguments on multiple expectations**

*Expect `a` to receive `:x` and `:y` messages with 1 and 2 arguments respectively:*

```ruby
expect(a).to_receive(:x, :y).with(1, 2)
```

for this test to pass, both `a.x(1)` and `a.y(2)` should be called.

You can also use a block to validate arguments.

*Expect `a` to receive `:x` and `:y` messages where x's argument is 1 and y's argument is bigger than 2:*

```ruby
expect(a).to_receive(:x, :y).with do |x,y|
  is(x) == 1
  is(y) >  2
end
```

Another way is to just return `true` or `false`. If block returns true, the test will pass.

```ruby
expect(a).to_receive(:x, :y).with {|x,y| x == 1 && y > 2}
```

[&#8679; Table of Contents](#docs)


#### &#8627; Returned value

*Expect `a` to receive `:b` message and return 'x':*

```ruby
expect(a).to_receive(:b).and_return('x')
```

*Expect `a` to receive `:b` message and return a value bigger than 10:*

```ruby
expect(a).to_receive(:b).and_return {|returned_value| is(returned_value) > 10}
```

Another way is to just return `true` or `false`. If block returns true, the test will pass.

```ruby
expect(a).to_receive(:b).and_return {|returned_value| returned_value > 10}
```


**&#8627; Returned value on multiple expectations**

*Expect `a` to receive `:x` and `:y` messages and return 1 and 2 respectively:*

```ruby
expect(a).to_receive(:x, :y).and_return(1, 2)
```

for this test to pass, `a.x` should return 1 and `a.y` should return 2.

If all messages expected to return same value, use a single argument.

*Expect `a` to receive `:x` and `:y` messages and both to return 1:*

```ruby
expect(a).to_receive(:x, :y).and_return(1)
```

for this to pass both `:x` and `:y` should return 1.

When you need full control over returned values, use a block.

*Expect `a` to receive `:x` and `:y` messages where `:x` will return 1 and `:y`  a value bigger than 5:*

```ruby
expect(a).to_receive(:x, :y).and_return do |x,y|
  is(x) == 1
  is(y) >  5
end
```

Another way is to just return `true` or `false`. If block returns true, the test will pass.

```ruby
expect(a).to_receive(:x, :y).and_return {|x,y| x == 1 && y > 5}
```

[&#8679; Table of Contents](#docs)


#### &#8627; Raised exception

When you expect a message to raise a exception, use `and_raise` expectation.

*Expect `a` to receive `:b` message and raise something:*

```ruby
expect(a).to_receive(:b).and_raise
```

When you expect a specific error, pass expected error class as first argument.

*Expect `a` to receive `:b` message and raise NoMethodError error:*

```ruby
expect(a).to_receive(:b).and_raise NoMethodError
```


When you expect a specific error with a specific message, pass expected error class and expected message wrapped into an array.

*Expect `a` to receive `:b` message and raise CustomError error with 'something went wrong' message:*

```ruby
expect(a).to_receive(:b).and_raise [CustomError, 'something went wrong']
```


When you need error message to match some string, use a Regexp.

*Expect `a` to receive `:b` message and raise CustomError error with a message that match `/something/`:*

```ruby
expect(a).to_receive(:b).and_raise [CustomError, /something/]
```

**When you need even more control over raised exception, use a block.**

*Expect `a` to receive `:b` message and raise anything but LoadError:*

```ruby
expect(a).to_receive(:b).and_raise do |e|
  assert(e).is_a?(Exception)
  assert(e.class) != LoadError
end
```

Another way is to just return `true` or `false`. If block returns true, the test will pass.

```ruby
expect(a).to_receive(:b).and_raise do |e|
  e.is_a?(Exception) && e.class != LoadError
end
```


**&#8627; Raised exception on multiple expectations**

*Expect `a` to receive `:x` and `:y` messages and both to raise something:*

```ruby
expect(a).to_receive(:x, :y).and_raise
```

If you expect a specific error for each message to be raised, just pass expected errors as arguments.

*Expect `a` to receive `:x` and `:y` messages where `:x` will raise NoMethodError error and `:y` will raise StandardError:*

```ruby
expect(a).to_receive(:x, :y).and_raise(NoMethodError, StandardError)
```

If you need also to check error messages, pass error class and message wrapped into an array.

*Expect `a` to receive `:x` and `:y` messages where `:x` will raise NoMethodError that match /X/ and `:y` will raise StandardError that match /Y/:*

```ruby
expect(a).to_receive(:x, :y).and_raise([NoMethodError, /X/], [StandardError, /Y/])
```

It's not a sin to expect only error type on some message and error type with message on another.

*Expect `a` to receive `:x` and `:y` messages where `:x` will raise NoMethodError and `:y` will raise StandardError that match /Y/:*

```ruby
expect(a).to_receive(:x, :y).and_raise(NoMethodError, [StandardError, /Y/])
```

**If all messages are expected to raise same error, use a single argument.**

*Expect `a` to receive `:x` and `:y` messages and both to raise StandardError:*

```ruby
expect(a).to_receive(:x, :y).and_raise(StandardError)
```

**It is also possible to use a block for validating raised exceptions.**<br>
The block will receive as many arguments as messages expected. Each argument will be a exception instance if its message raised something or `nil` otherwise.

*Expect `a` to receive `:x` and `:y` messages where `:x` will raise NoMethodError and `:y`'s backtrace will contain a specific line:*

```ruby
expect(a).to_receive(:x, :y).and_raise do |x,y|
  assert(x).is_a? NoMethodError
  assert(y.backtrace).any? {|l| l =~ /something/}
end
```

Another way is to just return `true` or `false`. If block returns true, the test will pass.

```ruby
expect(a).to_receive(:x, :y).and_raise do |x,y|
  x.is_a?(NoMethodError) && y.backtrace.any? {|l| l =~ /something/}
end
```


**&#8627; Assert nothing raised**

Often you need to assure some message received and nothing raised. There are `without_raise` expectation that will ensure nothing raised on message receiving.

*Expect `a` to receive `:b` and nothing raises:*

```ruby
expect(a).to_receive(:b).without_raise
```

Also works on multiple expectations. In this case the test will fail if at least one message raises a exception.

*Expect `a` to receive `:x` and `:y` without raise anything:*

```ruby
expect(a).to_receive(:x, :y).without_raise
```


[&#8679; Table of Contents](#docs)


#### &#8627; Thrown symbol

When you expect a symbol to be thrown, use `and_throw` expectation.

*Expect `a` to receive `:b` message and throw `:x` symbol:*

```ruby
expect(a).to_receive(:b).and_throw :x
```

**Note:** unlike `and_raise` expectation, `and_throw` can not be used without arguments. It requires exactly one argument - the expected symbol(unless a block used).

Also a block can be used to validate thrown symbol. This is the case when `and_throw` expectation should be used without arguments.

*Expect `a` to receive `:b` message and throw any symbol except `:x`:*

```ruby
expect(a).to_receive(:b).and_throw do |s|
  assert(s).is_a? Symbol # making sure something actually thrown
  assert(s) != :x
end
```

Another way is to just return `true` or `false`. If block returns true, the test will pass.

```ruby
expect(a).to_receive(:b).and_throw {|s| s.is_a?(Symbol) && s != :x }
```


**Limitations:** unlike `throw?` helper, expectations can only check for thrown symbol, so there is no way to get and validate thrown value with expectations.


**&#8627; Thrown symbol on multiple expectations**

When multiple messages expected, `and_throw` method will accept same number of arguments as the number of expected messages.

*Expect `a` to receive `:x` and `:y` messages and throw `:xs` and `:ys` symbols respectively:*

```ruby
expect(a).to_receive(:x, :y).and_throw(:sx, :sy)
```

If all messages are expected to raise same symbol, use a single argument.

*Expect `a` to receive `:x` and `:y` messages and both to throw `:halt` symbol:*

```ruby
expect(a).to_receive(:x, :y).and_throw(:halt)
```

When you need even more control over thrown symbols, use a block. The block will receive exactly same number of arguments as the number of expected messages. Each argument will be a symbol if its message thrown something of `nil` otherwise.

*Expect `a` to receive `:x` and `:y` messages where `:x` will thrown `:ok` symbol and `:y` will throw anything but `:halt` symbol:*

```ruby
expect(a).to_receive(:x, :y).and_throw do |x,y|
  is(x) == :ok
  assert(y).is_a? Symbol # making sure something actually thrown
  assert(y) != :halt
end
```

Another way is to just return `true` or `false`. If block returns true, the test will pass.

```ruby
expect(a).to_receive(:x, :y).and_throw do |x,y|
  x == :ok && y.is_a?(Symbol) &&  y != :halt
end
```

**&#8627; Assert nothing thrown**

*Expect `a` to receive `:b` message without throw any symbol:*

```ruby
expect(a).to_receive(:b).without_throw
```

*Expect `a` to receive `:x` and `:y` messages without throw any symbol:*

```ruby
expect(a).to_receive(:x, :y).without_throw
```


[&#8679; Table of Contents](#docs)


#### &#8627; Yielded arguments

`and_yield` expectation allow to check whether some block inside expected message yielded with specific arguments.

*Expect `a` to receive `:b` message and `:b` message to yield a block with 1, 2 arguments:*

```ruby
expect(a).to_receive(:b).and_yield(1, 2)
```

When you need more control, use a block.

*Expect `a` to receive `:b` message and `:b` message to yield a block where first argument is a string and last is a symbol:*

```ruby
expect(a).to_receive(:b).and_yield do |*args|
  assert(a.first).is_a? String
  assert(a.last).is_a?  Symbol
end
```

Another way is to just return `true` or `false`. If block returns true, the test will pass.

```ruby
expect(a).to_receive(:b).and_yield do |*args|
  a.first.is_a?(String) && a.last.is_a?(Symbol)
end
```


**&#8627; Yielded arguments on multiple expectations**

*Expect `a` to receive `:x` and `:y` messages where `:x` will yield a block with 1, 2 arguments and `:y` will yield a bloc with `:z` argument:*

```ruby
expect(a).to_receive(:x, :y).and_yield([1, 2], :z)
```

If all messages are expected to yield a block with same arguments, use a single argument on `and_yield` method.


*Expect `a` to receive `:x` and `:y` messages and both `:x` to yield a block  with `:z` argument:*

```ruby
expect(a).to_receive(:x, :y).and_yield(:z)
```


*Expect `a` to receive `:x` and `:y` messages and both to yield a block with 1, 2 arguments:*

```ruby
expect(a).to_receive(:x, :y).and_yield([1, 2])
```

Please note the arguments are wrapped into an array. If using `and_yield(1, 2)` instead, the test will expect `:x` to yield 1 and  `:y` to yield 2.

When you need full control over yielded arguments, use a block.

*Expect `a` to receive `:x` and `:y` messages where `:x` will yield a block with 2 or more arguments and `:y` will yield a bloc with integer only arguments:*

```ruby
expect(a).to_receive(:x, :y).and_yield do |*args|
  assert(args.first.size) >= 2
  assert(args.last).all? {|a| a.is_a? Integer}
end
```

Another way is to just return `true` or `false`. If block returns true, the test will pass.

```ruby
expect(a).to_receive(:x, :y).and_yield do |*args|
  args.first.size >= 2 && args.last.all? {|a| a.is_a? Integer}
end
```


**&#8627; Assert nothing yielded**

*Expect `a` to receive `:b` message without yield any block:*

```ruby
expect(a).to_receive(:b).without_yield
```

*Expect `a` to receive `:x` and `:y` messages without yield any block:*

```ruby
expect(a).to_receive(:x, :y).without_yield
```


[&#8679; Table of Contents](#docs)


#### &#8627; Messages Amount

`count`, or its alias `times`, allow to check how many times a specific message was received.

*Expect `a` to receive `:b` message exactly 2 times:*

```ruby
expect(a).to_receive(:b).count(2)
```

*Expect `a` to receive `:b` message 2 or more times:*

```ruby
expect(a).to_receive(:b).count {|n| n >= 2}
```


**&#8627; Amount on multiple expectations**

When multiple messages expected, `count` will receive an argument per each message.

*Expect `a` to receive `:x` message 2 times and `:y` message 5 times:*

```ruby
expect(a).to_receive(:x, :y).count(2, 5)
```

When all messages are expected to receive same amount of times, use a single argument.

*Expect `a` to receive `:x` and `:y` messages exactly 2 times each:*

```ruby
expect(a).to_receive(:x, :y).count(2)
```

*Expect `a` to receive `:x` message exactly 2 times and `:y` message at least once:*

```ruby
expect(a).to_receive(:x, :y).count {|x,y| x == 2 && y > 1}
```


[&#8679; Table of Contents](#docs)

#### &#8627; Messages Order

Unlike RSpec, ordering in Minispec works only with multiple messages.

*Expect `a` to receive `:x`, `:y`, `:z` messages exactly in specified order:*

```ruby
expect(a).to_receive(:x, :y, :z).ordered
```

If given messages will be received in another order, the test will fail.

It is also possible to check whether same sequence of messages received N times.

*Expect `a` to receive `:x`, `:y` sequence exactly 2 times:*

```ruby
expect(a).to_receive(:x, :y).ordered(2)
```

for this test to pass following code expected to be executed:

```ruby
a.x
a.y
a.x
a.y
```

if at least one message not received or received in wrong order, the test will fail.

When you need more flexibility on received sequence, use a block.

*Expect `a` to receive `:x`, `:y` sequence at least once:*

```ruby
expect(a).to_receive(:x, :y).ordered {|n| n >= 1}
```

[&#8679; Table of Contents](#docs)


### Spies

Just like expectations, spies checks for some object to receive specific message(s). The only logical difference is that spies assumes message(s) was already received rather than expects they to be received in the future.

Also there is a technical difference - while expectations does not require any preparations on the objects, spies does. You should explicitly "attach a spy" on the object and specify what methods to spy on, let the object to behave in its way and only after that you can check whether it received expected messages.

Attaching a spy on a object is easily done via `spy` method.<br>
Checking a message was received is done via `received` helper(or its sugar alias `received?`).

```ruby
user = User.new
spy(user, :location)  # attaching spy...
user.summary
assert(user).received(:location) # checking location message received
```

In terms of what happens after message received spies behaves exactly as expectations:

  * checks arguments message(s) was received with
    * `with`
  * validates returned value(s)
    * `and_returned`
  * checks for raised errors
    * `and_raised`
  * checks for thrown symbols
    * `and_thrown`
  * validates yielded arguments
    * `and_yielded`
  * checks how many times message(s) was received
    * `count`
  * checks messages was received in specific order
    * `ordered`


And just as with expectations, spies behaves well when dealing with multiple messages. Just attach a spy on multiple messages and validate them all at once:

```
spy(user, :name, :age, :location)
user.summary
assert(user).received(:name, :age, :location)
```


[&#8679; Table of Contents](#docs)


### Stubs

Minispec allows to stub any method on a given object and have full control over stub behavior.

*Add `:x` stub:*

```ruby
stub(some_object, :x)
```

`some_object.x` will return `nil`.

When you need a stub to return some value, regardless given arguments, use a Hash or a block.

*Add `:x` stub and make it return `:y`:*

```ruby
stub(some_object, :x => :y)
```

`some_object.x` will return `:y`.

*Add `:x` stub and make it return `:z`:*

```ruby
stub(some_object, :x) { :z }
```

now `some_object.x` will return `:z`.

**Important!** Stubs does not impose any restrictions on arity, so stubbed methods can be called with any arguments!

Given arguments will just be passed into the block, preceded by the original. That's it, the block will receive the original method as first argument. If stubbed method were not defined on that object before stubbing, the block will receive `nil` as first argument.

Another important note is that method's visibility are kept even after they are stubbed. So if some method exists on target object and it is protected, the stub that will override original method will be protected as well.<br>
Same for private and public methods.

And of course if we are stubbing some object that will still exists after test finished, the stubbed methods will be restored to their originals.


[&#8679; Table of Contents](#docs)


#### &#8627; Argument-vary stubs

Often you need a stub to behave in a way when receiving some arguments and another way when receiving another arguments.

At a first glance this could be done by comparing arguments inside the block:

*Bad!*

```ruby
stub(some_object, :some_method) do |orig, *args|
  if args == [:a, :b]
    # do this
  elsif args == [:x, :y]
    # do that
  end
end
```

however this approach is tedious(at least) and really ugly.

Recommended way here is to use a block with each sequence of arguments.

For this to work you'd need to use `with` method.<br>
It takes expected arguments and a block to be yielded when the stub called with given arguments:

```ruby
stub(some_object, :some_method).
  with(:a, :b) { 'called with a, b' }.
  with(:x, :y) { 'called with x, y' }
```

now `some_object.some_method(:a, :b)` will return 'called with a, b' and `some_object.some_method(:x, :y)` will return 'called with x, y'.

**However!** if called without arguments or with any arguments except [:a, :b] and [:x, :y], this example will actually return `nil`.

To define a "catchall" add one more block using `with_any`(or simply `any`):

```ruby
stub(some_object, :some_method).
  with(:a, :b) { 'called with a, b' }.
  with(:x, :y) { 'called with x, y' }.
  with_any { 'whatever' }
```

now when calling `some_method` **without arguments** or with **any arguments but** [:a, :b] and [:x, :y], it will return 'whatever'.

`with_any` can also be used with a value rather than a block. Also it can be placed anywhere in the chain, the order does not change the result:

```ruby
stub(some_object, :some_method).
  with_any('whatever').
  with(:a, :b) { 'called with a, b' }.
  with(:x, :y) { 'called with x, y' }
```


**One more note:** if you prefer a more verbose style you can use `stub` method multiple times:

```ruby
stub(some_object, :some_method).with(:a, :b) { 'called with a, b' }
stub(some_object, :some_method).with(:x, :y) { 'called with x, y' }
stub(some_object, :some_method).any { 'whatever' } # or `any('whatever')`
```

this will work exactly the same way as chained syntax.

[&#8679; Table of Contents](#docs)


#### &#8627; Stubbing multiple methods at once

Often you need to stub multiple methods and you feel that calling `stub` for each one is at least tedious.

And you will be right. Cause Minispec allows to add multiple stubs in one call. For this to work simply use `stubs` instead of `stub`.

*Stub `:x`, `:y` and `:z` methods on `cube`:*

```ruby
stubs(cube, :x, :y, :z)
```

**Worth to note** that given block will apply to all stubs.

*Stub `:x`, `:y` and `:z` methods on `cube` and make them all return the square of given value:*

```ruby
stubs(cube, :x, :y, :z) {|orig, n| n ** 2}
```

now `cube.x(2)` will return 4, `cube.y(4)` will return 16 etc.

Same for `with` and `with_any` methods - they apply to all stubbed methods without a way to different constraints for some stub:

```ruby
stubs(a, :b, :c).
  with(1) {:one}.
  with(2) {:two}.
  with_any {:whatever}
```

now both `a.b(1)` and `a.c(1)` will return :one, both `a.b(2)` and `a.c(2)` will return :two and any of `a.b`/`a.c` without arguments or with any arguments but 1 or 2 will return :whatever.

Also the method's visibility will be kept, so if some protected exists on target object, the stub will be protected as well. Same for private and public methods.

And of course multiple protected/private stubs can be defined by using `protected_stubs` and `private_stubs` accordingly.


[&#8679; Table of Contents](#docs)


#### &#8627; Chained stubs

When you need to stub a chain of methods in one statement use a string of dot separated methods:

```ruby
stub(a, 'x.y.z')
```

now `a.x.y.z` will work, though it will return `nil`.

When you need last method in the chain to return some value, use Hash or a block:

```ruby
stub(a, 'b.c' => :z)
```

now `a.b.c` will return `:z`.

```ruby
stub(a, 'b.c') { :x }
```

now `a.b.c` will return `:x`.

A important difference from regular stubs is that chained ones wont receive the original as first argument. They will only receive the arguments passed when stub called:

```ruby
stub(a, 'b.c') {|x| x ** 2}
a.b.c(4)
# => 16
```

If a block given when calling last method in the chain, it will be passed into the block alongside with any arguments. However you'll can not use `yield` here. You should receive it as argument and call it explicitly:

```ruby
stub(a, 'b.c') do |n, block|
  block.call(n)
end

a.b.c(4) {|y| y ** 2}
# => 16
```


**Important!** just like regular stubs, chained ones may have arguments-vary behavior:

```ruby
stub(a, 'b.c').
  with(1) {:one}.
  with(2) {:two}.
  with_any { :whatever }
```

now `a.b.c(1)` will return :one and `a.b.c(2)` will return :two. If called without arguments or with any but 1 or 2, it will return :whatever.

**Worth to note** that chained stubs does not care about method visibility. It will always define a public singleton method on the target object:

So, `stub(a, 'b.c')` will define `b` public singleton method on `a`, even if `b` exists and it is protected/private.<br>
That's the big difference from regular stubs where stubs keeps same visibility as original methods.

Please be aware that if the method to be stubbed already exists on the target object, it will be overridden for the time of test running and restored after the test finished.


[&#8679; Table of Contents](#docs)


#### &#8627; Calling original

If stubbed method already exists, the original method will be passed into block as first argument. Otherwise the block will receive `nil` as first argument.

```ruby
stub(API, :request) do |original, *args, &block|
  # call the original with given args and block
  original.call(*args, &block)
end
```

`API.request` will call our stub which will then call the original.


[&#8679; Table of Contents](#docs)


#### &#8627; Stubs visibility

Keeping the SUT(system under test) in nearly same state as it would act in a real environment is a high priority matter for Minispec.

That's why when it is stubbing methods it is keeping original method visibility. Meant if a method were protected before stubbing, the stub will be protected as well. Same for private and public methods.

However if you want to enforce specific visibility on stubbed method, use one of `public_stub`, `protected_stub` or `private_stub`.<br>
They will define a stub with a specific visibility regardless the visibility of original method.

And of course there are their counterparts for multiple stubbing: `public_stubs`, `protected_stubs` or `private_stubs`.


[&#8679; Table of Contents](#docs)


### Mocks

Basically a mock is a mix of a stub and a expectation. Meant that you do not need to separately stub a method then add an expectation on it. Mocks doing this automatically.

*Stub method `:x` and ensure it will be called by the end of test:*

```ruby
mock(some_object, :x)
```

that's it.

This is a replacement for:

```ruby
stub(some_object, :x)
expect(some_object).to_receive(:x)
```

**Worth to note** that expectations added by mocks are very basic ones, they will only expect message to be received. That's it, no arguments constraints, no returned value validation etc. If you need a more complex expectation you'll have to define it explicitly.

**Another important note:** `mock` method will actually return a stub, so you have full control over stubbed method's behavior.

*Mock method `:x` by making it return `:one` when called with 1:*

```ruby
mock(some_object, :x).with(1) { :one }
```

*Mock method `:x` by making it return `:one` when called with 1 and return 'whatever' when called with any other arguments or without arguments at all:*

```ruby
mock(some_object, :x).
  with(1) { :one }.
  with_any { 'whatever' }
```


**Mocks also works with Hashes.**

*Mock method `:a` to return `:x` and method `:b` to return `:y`:*

```ruby
mock(some_object, :a => :x, :b => :x)
```

And as with stubs you can not use arguments filters when mocked methods given as a Hash.<br>
This will raise an ArgumentError: `mock(some_object, :a => :x).with(...) {...}`.<br>
Same for `with_any`.


There is also a way to **mock multiple methods at once.**

For this simply use `mocks` instead of `mock`.

*Mock `:a` and `:b` methods:*

```ruby
mock(some_object, :a, :b)
```

for this to pass both `some_object.a` and `some_object.b` should be called.

When mocking multiple methods, the returned value will apply to all methods.

*Mock `:a` and `:b` and make them both to return `:x`:*

```ruby
mock(some_object, :a, :b) { :x }
```

There is no way to have specific setups when mocking multiple methods, that's it, all of them will behave the same way.

*Mock `:a` and `:b` and make them both to return `:one` when called with argument 1 and return `:two` when called with argument 2:*

```ruby
mock(some_object, :a, :b).
  with(1) { :one }.
  with(2) { :two }
```


**Mocks visibility rules** works the same as for stubs. If some protected method are mocked, the mocked version will be protected as well. Same for private and public methods.

However when you need a mock to be of specific visibility, use one of `public_mock`, `protected_mock` or `private_mock`.

And of course there are their counterparts for multiple mocking: `public_mocks`, `protected_mocks` or `private_mocks`.


One **significant difference** between mocks and stubs is that mocks does not support chained methods. That's it, you can not do like this: `mock(some_object, 'a.b.c')`. Instead you should stub the chain then explicitly define expectations:

```ruby
stub(some_object, 'a.b.c')
expect(some_object).to_receive(:a)
expect(some_object.a).to_receive(:b)
# ...
```


[&#8679; Table of Contents](#docs)


### Doubles

During testing you may need entities that behaves like some "real" objects.

Let's say you need to ensure a welcome email is sent to user after account creation.

Rather than create a full-blown mail object you can use a double that behaves like a mailer, e.g. responds to `deliver`.

To create a double simply use the `double` method:

```ruby
email = 'bob@bobsen.com'

# creating mailer double
mailer = double(:mailer, deliver: true)

# ensuring `deliver` will be called with user's email
expect(mailer).to_receive(:deliver).with(user.email)

# injecting double into system
User.new!(email: email, mailer: mailer)
```

For this contrived test to pass, `mailer#deliver` should be called under the hood.

If one or more arguments given to `double` method, first argument will be used as name(unless it is a Hash). Double's name turns to be very helpful on failures output, so a real name will output rather than `#<Object...` notation.

[&#8679; Table of Contents](#docs)


## Running Specs

Minispec will look for specs in `./spec` and `./test` folders.

Any files that match `*_spec.rb`, `*_test.rb` or `test_*.rb` will be loaded by Minispec.

So if you go standard way and put name you spec files like this and put them in `spec` or `test` folder, all you need to run specs is to call `minispec` in you terminal:

```bash
$ minispec
```

If you want to test only some files, pass them as space delimited arguments:

```bash
$ minispec spec/user_spec.rb spec/cart_spec.rb
```

If you need to run specs from a script, use `Minispec.run`.

*Rakefile*

```ruby
require 'minispec'
desc 'Run all tests'
task :test do
  Minispec.run
end
```

`run` accepts `pattern` option, so you can instruct Minispec on how to load your specs:


```ruby
require 'minispec'

namespace :test do
  
  desc 'Run user tests'
  task :users do
    Minispec.run(pattern: 'test/**/user*.rb')
  end
end
```


Also `:file` option accepted so you can run a single file:

```ruby
require 'minispec'

Dir['test/**/test_*.rb'].each do |file|
  name = file.sub(/test\/test_(.+)\.rb/, '\1')
  desc 'Run %s tests' % name
  task 'test:' + name do
    Minispec.run(file: file)
  end
end
```


[&#8679; Table of Contents](#docs)


## Contributors

Want to contribute? Great! Contributors highly wanted and welcome!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

Copyright &copy; 2014 Slee Woo &lt;mail@sleewoo.com&gt;

Distributed under the **[MIT License](https://github.com/sleewoo/minispec/blob/master/LICENSE)**
