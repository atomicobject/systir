require 'systir'

class BasicDriver < Systir::LanguageDriver
  def setup
    # Run before each .test
    puts "Setup complete"
  end

  def teardown
    # Run after each .test
    puts "Tear-down complete"
  end

  def do_something_basic
    puts "Doing something really basic"
    assert true, "The truth is out there"
  end
  
end
