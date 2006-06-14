#!/usr/bin/ruby

require File.dirname(__FILE__) + '/test_helper'

class LanguageDriverTest < Test::Unit::TestCase
  class BogusHelper
    attr_accessor :driver
  end

  def setup
    @driver = Systir::LanguageDriver.new('test_BOGUS')
    @helper = BogusHelper.new
  end

  #
  # See that associate_helper causes the driver to set a self-reference
  # on the given helper and returns the helper
  #
  def test_associate_helper
    assert_nil @helper.driver
    got = @driver.associate_helper(@helper)
    assert_equal @driver, @helper.driver
    assert_equal @helper, got, "wrong return"
  end
  # (return_helper is an alias of associate_helper)
  def test_return_helper
    assert_nil @helper.driver
    got = @driver.return_helper(@helper)
    assert_equal @driver, @helper.driver
    assert_equal @helper, got, "wrong return"
  end
  # (return_helper is an alias of associate_helper)
  def test_hand_off_to
    assert_nil @helper.driver
    got = @driver.hand_off_to(@helper)
    assert_equal @driver, @helper.driver
    assert_equal @helper, got, "wrong return"
  end

  # See that collect_assertion calls add_assertion
  def collect_assertion
    @driver.extend Bogus
    @driver.bogify :add_assertion

    assert_nil @driver._calls
    @driver.collect_assertion
    assert_equal [:add_assertion], @driver._calls
  end

end
