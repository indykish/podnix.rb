require File.expand_path("#{File.dirname(__FILE__)}/test_helper")
class TestApps < MiniTest::Unit::TestCase
  #=begin

  def test_get_images

    response = podnix.get_images
    assert_equal(200, response.status)
    response.data[:body]['data'].each do |im|
    end
  end



 
end

