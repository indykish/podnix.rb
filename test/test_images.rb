require File.expand_path("#{File.dirname(__FILE__)}/test_helper")
class TestApps < MiniTest::Unit::TestCase
  #=begin

  def test_get_images

    response = podnix.get_images
    assert_equal(200, response.status)
    puts "IMAGE ID <------> IMAGE NAME"
    response.data[:body]['data'].each do |im|
      	puts "#{im['id']}		#{im['name']}"
    end
  end



 
end

