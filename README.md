# knife-maas

This is the knife plugin to talk to [MaaS](http://maas.ubuntu.com/).

## Installation

Run the following to install the plugin.

```ruby
gem 'knife-maas'
```
## Usage

### knife.rb options

`knife[:maas_site]` - The MaaS that you'd like to interact with, ex: "http://172.16.100.54/MAAS/"
`knife[:maas_api_key]` = The MaaS API key from your settings page, ex: "Dce3YFAKEY3f9Lvm:jfPMAASfgDVbjR9:jS6JPX8bKEYFp8W2DR7MBuPb9QrEFbYT"

## Commands

`knife maas server list` - Outputs the nodes inside on MaaS

`knife maas server start -s NODE-(UUID)` - Starts up the node

`knife maas server stop -s NODE-(UUID)` - Stops the node

`knife maas server release -s NODE-(UUID)`- Releases the node

`knife maas server delete -s NODE-(UUID)` - Removes the node from MaaS



## Contributing

1. Fork it ( https://github.com/jjasghar/knife-maas/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
