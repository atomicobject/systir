require 'systir'
Test::Unit.run = false
require 'tutils/bogus'
require 'tutils/ext_assertions'
require 'test/unit'

# = DESCRIPTION
# This is the unit test suite for the Systir modules and classes.
#

###########################################################################
# UTILS

# Use the directory of this test file to prepend to fname
def relfile(fname)
  File.dirname(__FILE__) + "/#{fname}"
end

###########################################################################

class Systir::LanguageDriver
  # Since a LanguageDriver is a kind of TestCase,
  # and you must have at least one test method if you
  # are a TestCase, we must add a bogus filler method here:
	# (because we're going to construct a new LanguageDriver in the systir test)
  def test_BOGUS
  end
end
