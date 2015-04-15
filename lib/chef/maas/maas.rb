require 'chef/maas/version'
require 'chef/maas/client'

module Maas
  NODE_STATUS_MAP = {
    '-1' => { color: :red, status: 'unknown' },
    '0' => { color: :yellow, status: 'new' },
    '1' => { color: :yellow, status: 'commissioning' },
    '2' => { color: :red, status: 'failed_commissioning' },
    '3' => { color: :red, status: 'missing' },
    '4' => { color: :green, status: 'ready' },
    '5' => { color: :yellow, status: 'reserved' },
    '6' => { color: :green, status: 'deployed' },
    '7' => { color: :yellow, status: 'retired' },
    '8' => { color: :red, status: 'broken' },
    '9' => { color: :yellow, status: 'deploying' },
    '10' => { color: :yellow, status: 'allocated' },
    '11' => { color: :red, status: 'failed_deployment' },
    '12' => { color: :yellow, status: 'releasing' },
    '13' => { color: :red, status: 'failed_releasing' },
    '14' => { color: :yellow, status: 'disk_erasing' },
    '15' => { color: :red, status: 'failed_disk_erasing' }
  }
end
