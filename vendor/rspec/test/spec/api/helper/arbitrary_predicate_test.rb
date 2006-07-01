require File.dirname(__FILE__) + '/../../../test_helper'

module Spec
  module Api
    module Helper

      class ArbitraryPredicateTest < Test::Unit::TestCase

        # should.be.funny

        def test_should_be_funny_should_raise_when_target_doesnt_understand_funny
          assert_raise(NoMethodError) do
            5.should.be.funny
          end
        end

        def test_should_be_funny_should_raise_when_sending_funny_to_target_returns_false
          mock = HandCodedMock.new(false)
          assert_raise(ExpectationNotMetError) do
            mock.should.be.funny
          end
          mock.__verify
        end

        def test_should_be_funny_should_raise_when_sending_funny_to_target_returns_nil
          mock = HandCodedMock.new(nil)
          assert_raise(ExpectationNotMetError) do
            mock.should.be.funny
          end
          mock.__verify
        end

        def test_should_be_funny_should_not_raise_when_sending_funny_to_target_returns_true
          mock = HandCodedMock.new(true)
          assert_nothing_raised do
            mock.should.be.funny
          end
          mock.__verify
        end

        def test_should_be_funny_should_not_raise_when_sending_funny_to_target_returns_something_other_than_true_false_or_nil
          mock = HandCodedMock.new(5)
          assert_nothing_raised do
            mock.should.be.funny
          end
          mock.__verify
        end

        # should.be.funny(args)
  
        def test_should_be_funny_with_args_passes_args_properly
           mock = HandCodedMock.new(true)
          assert_nothing_raised do
            mock.should.be.hungry(1, 2, 3)
          end
          mock.__verify
        end

        # should.not.be.funny

        def test_should_not_be_funny_should_raise_when_target_doesnt_understand_funny
          assert_raise(NoMethodError) do
            5.should.not.be.funny
          end
        end

        def test_should_not_be_funny_should_raise_when_sending_funny_to_target_returns_true
          mock = HandCodedMock.new(true)
          assert_raise(ExpectationNotMetError) do
            mock.should.not.be.funny
          end
          mock.__verify
        end

        def test_should_not_be_funny_shouldnt_raise_when_sending_funny_to_target_returns_nil
          mock = HandCodedMock.new(nil)
          assert_nothing_raised do
            mock.should.not.be.funny
          end
          mock.__verify
        end

        def test_should_not_be_funny_shouldnt_raise_when_sending_funny_to_target_returns_false
          mock = HandCodedMock.new(false)
          assert_nothing_raised do
            mock.should.not.be.funny
          end
          mock.__verify
        end

        def test_should_not_be_funny_should_raise_when_sending_funny_to_target_returns_something_other_than_true_false_or_nil
          mock = HandCodedMock.new(5)
          assert_raise(ExpectationNotMetError) do
            mock.should.not.be.funny
          end
          mock.__verify
        end
  
        # should.be.funny(args)
  
        def test_should_not_be_funny_with_args_passes_args_properly
           mock = HandCodedMock.new(false)
          assert_nothing_raised do
            mock.should.not.be.hungry(1, 2, 3)
          end
          mock.__verify
        end

      end
    end
  end
end
