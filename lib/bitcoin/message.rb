module Bitcoin
  module Message

    autoload :Handler, 'bitcoin/message/handler'
    autoload :Base, 'bitcoin/message/base'
    autoload :Inventory, 'bitcoin/message/inventory'
    autoload :InventoriesParser, 'bitcoin/message/inventories_parser'
    autoload :Version, 'bitcoin/message/version'
    autoload :VerAck, 'bitcoin/message/ver_ack'
    autoload :Addr, 'bitcoin/message/addr'
    autoload :Ping, 'bitcoin/message/ping'
    autoload :Pong, 'bitcoin/message/pong'
    autoload :Inv, 'bitcoin/message/inv'
    autoload :GetData, 'bitcoin/message/get_data'
    autoload :NotFound, 'bitcoin/message/not_found'
    autoload :Error, 'bitcoin/message/error'

    HEADER_SIZE = 24
    USER_AGENT = "/bitcoinrb:#{Bitcoin::VERSION}/"

    SERVICE_UNMAMED = 0 # not full node
    SERVICE_NODE_NETWORK = 1 # full node
  end
end