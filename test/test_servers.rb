require File.expand_path("#{File.dirname(__FILE__)}/test_helper")
class TestApps < MiniTest::Unit::TestCase


# https://api.podnix.com/servers/list?key=XXX
  def test_get_servers
    response = podnix.get_servers
    assert_equal(200, response.status)
  end



#STATUS 0=pending, 1=running, 2=deleted, 3=stopped 

  def test_get_server
    response = podnix.get_server({:id => '395'})
    assert_equal(200, response.status)
  end

#---------------------------------
#MODELS 	ID	VCORE	 RAM(GB)
#Small		1	1	2
#Medium		2	2	4
#Large		4	4	8
#Jumbo		8	8	16
#---------------------------------
#IMAGES				ID	
#Ubuntu 12.04.2 LTS (64bit)	2
#Ubuntu 13.04 (64bit)		37
#-----------------------------------
#PASSWORD
# Must contain at least 9 chars and include a lower case char, an upper case char and a number.

#SSD Not require,.If this parameter is set to 1, the system drive will be located on a SSD drive.

#STORAGE (10 - 200)

# https://api.podnix.com/servers/add?&name=test&model=1&image=2&password=Secret123&ssd=1&storage=10&key=XXX


def test_add_server
tmp_hash = {
:name => "tom.megam.co",
:model => "1",
:image => "37",
:password => "Team4megam",
:ssd => "1",
:storage => 10
}
response = podnix.add_server({
:name => "tom.megam.co",
:model => "1",
:image => "37",
:password => "Team4megam",
:ssd => "1",
:storage => '10'
})
assert_equal(201, response.status)
end

def test_start_Server
response = podnix.start_server({:id => '401'})
assert_equal(201, response.status)
end



def test_stop_Server
response = podnix.stop_server({:id => '401'})
assert_equal(201, response.status)
end

def test_delete_Server
response = podnix.delete_server({:id => '401'})
assert_equal(201, response.status)
end

end

