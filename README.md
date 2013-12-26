Podnix Ruby Client (Work In Progress)
==================

The Podnix Ruby Client is used to interact with the podnix API from Ruby.

For more about the Podnix API see <http://api.podnix.com>.

[![Build Status](https://travis-ci.org/indykish/podnix.png)](https://travis-ci.org/indykish/podnix)

We use podnix to launch instances. If you need a [Platform as Service:](https://www.megam.co)

Installation
------------
    gem install podnix
    
For Gemfile

    gem "podnix"
Usage
-----

Start by creating a connection to podnix with your credentials:

    require 'podnix'

    podnix = Podnix::API.new({:key => "PODNIX_API_KEY"})

Now you can make requests to the api.

Requests
--------

What follows is an overview of commands you can run for the client.

For additional details about any of the commands, see the [API docs](http://api.podnix.com).

### Images

Get the list of all images

    podnix.get_images

### Servers

Get the list of all  your nodes

    podnix.get_servers

Get details of a particular node

    podnix.get_server({:id => "123"})

Creates a server in podnix(www.podnix.com) cloud named "POGO". Password must contain at least 9 chars and include a lower case char, an upper case char and a number.

    podnix.create({:name => "POGO", :model => "1", :image => "37", :password => "Secret123", :ssd => "1", :storage => 10})

Start a node

    podnix.start_server({:id => '123'})

Stop a node

    podnix.stop_server({:id => '123'})

Delete a node

    podnix.delete_server({:id => '123'})


We are glad to help if you have questions, or request for new features.

[twitter](http://twitter.com/indykish) [email](<alrin@megam.co.in>)

#### TO - DO

* This is a work in progress. 
	
# License

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | Kishorekumar Neelamegam (<nkishore@megam.co.in>)
|                      | Thomas Alrin (<alrin@megam.co.in>)
| **Copyright:**       | Copyright (c) 2012-2013 Megam Systems.
| **License:**         | Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

