require File.expand_path("#{File.dirname(__FILE__)}/test_helper")
class TestApps < MiniTest::Unit::TestCase
  #=begin

  def test_get_models

    response = podnix.get_models
    assert_equal(200, response.status)
  end



 
end

