# encoding: UTF-8

class MinispecTest
  class Asserts < self
    module Mixin
      STRING = 'abc'
      TAINTED_STRING = 'tainted'.taint
      UNTRUSTED_STRING = 'untrusted'.untrust
      ARRAY = [1, '2', 'three']
      HASH = {foo: :bar}
      INTEGER = 2.freeze # on jruby integers are not frozen
      FLOAT = 2.0
      NIL = nil

      class Unit
        include Minispec
        continue_on_failures true
      end

      Unit.test :== do
        is(STRING) == %[abc]
        assert(INTEGER) == FLOAT
      end
      def test_equality
        assert STRING == 'abc'
        assert INTEGER == FLOAT
        assert passed(:==)
      end
      Unit.test ':== generates a failure' do
        is(STRING) == 'a'
      end
      def test_failure_of_equality
        assert failed(:==)
      end


      Unit.test :=== do
        check(STRING) === 'ABC'.downcase
        prove(String) === STRING
        check(Array)  === ARRAY
        assume(Hash)  === HASH
      end
      def test_case_equality
        assert STRING === 'ABC'.downcase
        assert String === STRING
        assert Array  === ARRAY
        assert Hash   === HASH
        assert passed(:===)
      end
      Unit.test ':=== generates a failure' do
        check(STRING) === 'ABC'
      end
      def test_failure_of_case_equality
        assert failed(:===)
      end


      Unit.test :eql? do
        is(STRING).eql? 'cba'.reverse
        refute(INTEGER).eql? FLOAT
      end
      def test_eql?
        assert STRING.eql?('cba'.reverse)
        refute INTEGER.eql?(FLOAT)
        assert passed(:eql?)
      end
      Unit.test ':eql? generates a failure' do
        is(STRING).eql? 'cba'
      end
      def test_failure_of_eql?
        assert failed(:eql?)
      end


      Unit.test :equal? do
        is(STRING).equal? STRING
        refute('a').equal? 'a'
      end
      def test_equal?
        assert STRING.equal?(STRING)
        refute 'a'.equal?('a')
        assert passed(:equal?)
      end
      Unit.test ':equal? generates a failure' do
        is(STRING).equal? 'abc'
      end
      def test_failure_of_equal?
        assert failed(:equal?)
      end


      Unit.test :empty? do
        refute(STRING).empty?
        refute(ARRAY).empty?
        refute(HASH).empty?
        is([]).empty?
        is({}).empty?
      end
      def test_empty?
        refute STRING.empty?
        refute ARRAY.empty?
        refute HASH.empty?
        assert [].empty?
        assert({}.empty?)
        assert passed(:empty?)
      end
      Unit.test ':empty? generates a failure' do
        is(STRING).empty?
      end
      def test_failure_of_empty?
        assert failed(:empty?)
      end


      Unit.test :=~ do
        assume(STRING) =~ /a/
      end
      def test_tilde_match
        assert(STRING =~ /a/)
        assert passed(:=~)
      end
      Unit.test ':=~ generates a failure' do
        assume(STRING) =~ /z/
      end
      def test_failure_of_tilde_match
        assert failed(:=~)
      end


      Unit.test :match do
        expect(STRING).match /b/
      end
      def test_match
        assert STRING.match(/b/)
        assert passed(:match)
      end
      Unit.test ':match generates a failure' do
        expect(STRING).match /bar/
      end
      def test_failure_of_match
        assert failed(:match)
      end


      Unit.test :include? do
          does(STRING).include? 'c'
          does(ARRAY).include? 1
      end
      def test_include?
        assert STRING.include?('c')
        assert ARRAY.include?(1)
        assert passed(:include?)
      end
      Unit.test ':include? generates a failure' do
        does(STRING).include? 'z'
      end
      def test_failure_of_include?
        assert failed(:include?)
      end


      Unit.test :any? do
        are(ARRAY).any? {|x| x.to_i > 1}
        has(HASH).any? {|k,v| k == :foo}
      end
      def test_any?
        assert ARRAY.any? {|x| x.to_i > 1}
        assert HASH.any? {|k,v| k == :foo}
        assert passed(:any?)
      end
      Unit.test ':any? generates a failure' do
        has(HASH).any? {|k,v| k == :baz}
      end
      def test_failure_of_any?
        assert failed(:any?)
      end

      Unit.test :all? do
        expect(ARRAY).all? {|v| v.to_i > -1}
        verify(HASH).all? {|k,v| v}
      end
      def test_all?
        assert ARRAY.all? {|v| v.to_i > -1}
        assert HASH.all? {|k,v| v}
        assert passed(:all?)
      end
      Unit.test ':all? generates a failure' do
        verify(HASH).all? {|k,v| v == :blah}
      end
      def test_failure_of_all?
        assert failed(:all?)
      end


      Unit.test :start_with? do
        does(STRING).start_with? 'a'
      end
      def test_start_with?
        assert STRING.start_with?('a')
        assert passed(:start_with?)
      end
      Unit.test ':start_with? generates a failure' do
        does(STRING).start_with? 'blah'
      end
      def test_failure_of_start_with?
        assert failed(:start_with?)
      end

      Unit.test :end_with? do
        does(STRING).end_with? 'c'
      end
      def test_end_with?
        assert STRING.end_with?('c')
        assert passed(:end_with?)
      end
      Unit.test ':end_with? generates a failure' do
        does(STRING).end_with? 'doh'
      end
      def test_failure_of_end_with?
        assert failed(:end_with?)
      end

      Unit.test :valid_encoding? do
        has(STRING).valid_encoding?
      end
      def test_valid_encoding?
        assert STRING.valid_encoding?
        assert passed(:valid_encoding?)
      end
      Unit.test ':valid_encoding? generates a failure' do
        refute(STRING).valid_encoding?
      end
      def test_failure_of_valid_encoding?
        assert failed(:valid_encoding?)
      end

      Unit.test :ascii_only? do
        is(STRING).ascii_only?
      end
      def test_ascii_only?
        assert STRING.ascii_only?
        assert passed(:ascii_only?)
      end
      Unit.test ':ascii_only? generates a failure' do
        is('ё').ascii_only?
      end
      def test_failure_of_ascii_only?
        assert failed(:ascii_only?)
      end

      Unit.test :> do
        is(FLOAT) > 0
        is('b') > 'a'
      end
      def test_bt
        assert(FLOAT > 0)
        assert('b' > 'a')
        assert passed(:>)
      end
      Unit.test ':> generates a failure' do
        is('a') > 'b'
      end
      def test_failure_of_bt
        assert failed(:>)
      end

      Unit.test :>= do
        is(INTEGER) >= FLOAT
        is(STRING) >= 'ab'
      end
      def test_bte
        assert(INTEGER >= FLOAT)
        assert(STRING >= 'ab')
        assert passed(:>=)
      end
      Unit.test ':>= generates a failure' do
        is(STRING) >= 'xyz'
      end
      def test_failure_of_bte
        assert failed(:>=)
      end

      Unit.test :< do
        is(0) < INTEGER
        is('a') < 'b'
      end
      def test_lt
        assert(0 < INTEGER)
        assert('a' < 'b')
        assert passed(:<)
      end
      Unit.test ':< generates a failure' do
        is('b') < 'a'
      end
      def test_failure_of_lt
        assert failed(:<)
      end

      Unit.test :<= do
        is(FLOAT) <= INTEGER
        is(STRING) <= 'abcd'
      end
      def test_lte
        assert(FLOAT <= INTEGER)
        assert(STRING <= 'abcd')
        assert passed(:<=)
      end
      Unit.test ':<= generates a failure' do
        is(STRING) <= '0'
      end
      def test_failure_of_lte
        assert failed(:<=)
      end

      Unit.test :between? do
        is(FLOAT).between? FLOAT, INTEGER
        is('b').between? 'a', 'c'
      end
      def test_between?
        assert(FLOAT.between? FLOAT, INTEGER)
        assert('b'.between? 'a', 'c')
        assert passed(:between?)
      end
      Unit.test ':between? generates a failure' do
        is('b').between? 'x', 'y'
      end
      def test_failure_of_between?
        assert failed(:between?)
      end

      Unit.test :nil? do
        is(NIL).nil?
        refute(STRING).nil?
      end
      def test_nil?
        assert(NIL.nil?)
        refute STRING.nil?
        assert passed(:nil?)
      end
      Unit.test ':nil? generates a failure' do
        is(STRING).nil?
      end
      def test_failure_of_nil?
        assert failed(:nil?)
      end

      Unit.test :!~ do
        prove(STRING) !~ /z/
      end
      def test_not_match
        assert(STRING !~ /z/)
        assert passed(:!~)
      end
      Unit.test ':!~ generates a failure' do
        prove(STRING) !~ /a/
      end
      def test_failure_of_not_match
        assert failed(:!~)
      end

      Unit.test :tainted? do
        is(TAINTED_STRING).tainted?
        refute(STRING).tainted?
      end
      def test_tainted?
        assert TAINTED_STRING.tainted?
        refute STRING.tainted?
        assert passed(:tainted?)
      end
      Unit.test ':tainted? generates a failure' do
        is(STRING).tainted?
      end
      def test_failure_of_tainted?
        assert failed(:tainted?)
      end

      Unit.test :untrusted? do
        is(UNTRUSTED_STRING).untrusted?
        refute(STRING).untrusted?
      end
      def test_untrusted?
        assert UNTRUSTED_STRING.untrusted?
        refute STRING.untrusted?
        assert passed(:untrusted?)
      end
      Unit.test ':untrusted? generates a failure' do
        is(STRING).untrusted?
      end
      def test_failure_of_untrusted?
        assert failed(:untrusted?)
      end

      Unit.test :frozen? do
        refute(STRING).frozen?
        is('smth'.freeze).frozen?
        negate(ARRAY).frozen?
        is(INTEGER).frozen?
      end
      def test_frozen?
        refute STRING.frozen?
        assert 'smth'.freeze.frozen?
        refute ARRAY.frozen?
        assert INTEGER.frozen?
        assert passed(:frozen?)
      end
      Unit.test ':frozen? generates a failure' do
        is(STRING).frozen?
      end
      def test_failure_of_frozen?
        assert failed(:frozen?)
      end

      Unit.test :instance_of? do
        check(STRING).instance_of? String
        negate(ARRAY).instance_of? Enumerable
      end
      def test_instance_of?
        assert STRING.instance_of?(String)
        refute ARRAY.instance_of?(Enumerable)
        assert passed(:instance_of?)
      end
      Unit.test ':instance_of? generates a failure' do
        check(STRING).instance_of? Array
      end
      def test_failure_of_instance_of?
        assert failed(:instance_of?)
      end

      Unit.test :kind_of? do
        is(STRING).kind_of? String
        is(ARRAY).kind_of? Enumerable
      end
      def test_kind_of?
        assert STRING.kind_of?(String)
        assert ARRAY.kind_of?(Enumerable)
        assert passed(:kind_of?)
      end
      Unit.test ':kind_of? generates a failure' do
        is(STRING).kind_of? Hash
      end
      def test_failure_of_kind_of?
        assert failed(:kind_of?)
      end

      Unit.test :is_a? do
        check(STRING).is_a? String
        assert(HASH).is_a? Hash
      end
      def test_is_a?
        assert STRING.is_a?(String)
        assert HASH.is_a?(Hash)
        assert passed(:is_a?)
      end
      Unit.test ':is_a? generates a failure' do
        check(STRING).is_a? Symbol
      end
      def test_failure_of_is_a?
        assert failed(:is_a?)
      end

      Unit.test :respond_to? do
        does(STRING).respond_to? :ascii_only?
        does(ARRAY).respond_to? :any?
        does(HASH).respond_to? :any?
      end
      def test_respond_to?
        assert STRING.respond_to?(:ascii_only?)
        assert(ARRAY).respond_to?(:any?)
        assert(HASH).respond_to?(:any?)
        assert passed(:respond_to?)
      end
      Unit.test ':respond_to? generates a failure' do
        does(STRING).respond_to? :blah
      end
      def test_failure_of_respond_to?
        assert failed(:respond_to?)
      end

      Unit.test :!= do
        check(STRING) != 'blah'
        negate(ARRAY) != ARRAY
      end
      def test_not_equal
        assert(STRING != 'blah')
        refute(ARRAY != ARRAY)
        assert passed(:!=)
      end
      Unit.test ':!= generates a failure' do
        check(STRING) != STRING
      end
      def test_failure_of_not_equal
        assert failed(:!=)
      end

      def passed test
        self.class::Status[test] == 0
      end
      def failed test
        self.class::Status[':%s generates a failure' % test] == 1
      end
    end
    include Mixin

    result = msrun(Unit)
    Status = result.status
  end
end

# running same tests but this time with proxified objects
require File.expand_path('../proxified_asserts', __FILE__)
