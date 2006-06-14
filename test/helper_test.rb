#!/usr/bin/ruby

require File.dirname(__FILE__) + '/test_helper'

class HelperTest < Test::Unit::TestCase
  # Helper is a mixin; let's make something concrete:
  class MyHelper 
    include Systir::Helper

    # Because add_assertion is private...
    def _call_add_assertion
      add_assertion
    end
  end

  def setup 
    # Bogus driver
    @driver = Object.new
    @driver.extend Bogus
    @driver.bogify :collect_assertion
  end

  # See the constructor stores a driver ref
  def test_constructor
    h = MyHelper.new(@driver)
    assert_not_nil h, "failed to construct"
    assert_equal @driver, h.driver, "driver ref not set"
  end
  
  # See the constructor considers driver to be optional 
  def test_constructor_no_driver
    h = MyHelper.new
    assert_not_nil h, "failed to construct"
  end

  # See that we can set and get the driver
  def test_driver_accessor
    h = MyHelper.new
    h.driver = @driver
    assert_equal @driver, h.driver, "driver not gotten"
  end

  # See that the driver getter explodes if driver is unset
  def test_driver_getter_nil
    h = MyHelper.new
    err = assert_raise RuntimeError  do
      h.driver
    end
    assert_match(/reference.*driver/i, err.message) 
  end

  # See that add_assertion() calls collect_assertion on the driver
  def test_add_assertion
    h = MyHelper.new(@driver)
    assert_nil @driver._calls, 'Expected no calls yet'
    h._call_add_assertion
    assert_equal [:collect_assertion], @driver._calls
  end

  # See that add_assertion() raises err if driver is unset
  def test_add_assertion_no_driver
    h = MyHelper.new
    err = assert_raise RuntimeError  do
      h._call_add_assertion
    end
    assert_match(/helper.*no.*reference.*driver/, err.message)
  end

  # See that add_assertion() raises err if driver hasn't got collect_assertion
  def test_add_assertion_bad_driver
    h = MyHelper.new(Object.new)
    err = assert_raise RuntimeError  do
      h._call_add_assertion
    end
    assert_match(/collect_assertion/, err.message)
  end
end

