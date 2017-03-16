# knife-maas

[![Build Status](https://travis-ci.org/jjasghar/knife-maas.svg?branch=master)](https://travis-ci.org/jjasghar/knife-maas)

This is the knife plugin to talk to [MAAS](http://maas.ubuntu.com/). This also assumes you have MAAS
configured with at least one user account. You'll need your API key as one of the
configuration options. There is a [MAAS cookbook](https://supermarket.chef.io/cookbooks/maas) that
this plugin has been tested against.

This also assumes you have >= 1.7.1 of MAAS installed, and >= [Chef](http://chef.io) 12 installed.

The version `2.0.0`+ of this knife plugin, requires version 2.0 of MAAS API.

Please refer to the [CHANGELOG](CHANGELOG.md) for version history.

## Installation

Run the following to install the plugin.

```shell
gem install knife-maas
```

## Usage

### Configuration

`knife[:maas_site]` - The MAAS that you'd like to interact with, ex: `"http://172.16.100.54/MAAS/"`, you'll need the ending `/` like the web gui.

`knife[:maas_api_key]` - The MAAS API key from your settings page, ex: `"Th1sIsFAKEY3f9Lvm:jaaMAASfgDVbjR9:jS6JPX8bKEYFp8W2DR7MBuPb9QrEFbYT"`

## Commands

**Note**: Due to some limitations in the [MAAS API](http://maas.ubuntu.com/docs1.7/api.html) anything that has both `-h` and
`-s` are required to function. Hopefully future releases will only require one option.

`knife maas server list` - Outputs the nodes inside on MAAS

`knife maas server <subcommand> --help` - is available and there are other options that aren't listed here. These are the most commonly used ones.

`knife maas server acquire` - Acquires a node under your account

`knife maas server bootstrap` - Acquires and starts a node under your account, and bootstraps chef on it with your default settings

`knife maas server start -s NODE-(UUID)` - Starts up the node

`knife maas server stop -s NODE-(UUID)` - Stops the node

`knife maas server release -s NODE-(UUID) -h HOSTNAME`- Releases the node and puts it back in the available resources. This also has a `-P` command to purge it from your chef server.

`knife maas server delete -s NODE-(UUID) -h HOSTNAME` - Removes the node completely from MAAS. This also has a `-P` command to purge it from your chef server.

## Contributing

1. Fork it ( https://github.com/jjasghar/knife-maas/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License
Author:: JJ Asghar <jj@chef.io>

Copyright:: Copyright (c) 2015 Chef Software, Inc.

License:: Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the License at

```
http://www.apache.org/licenses/LICENSE-2.0
```

Unless required by applicable law or agreed to in writing, software distributed under the
License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
either express or implied. See the License for the specific language governing permissions
and limitations under the License.
