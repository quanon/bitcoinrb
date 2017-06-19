module Bitcoin
  module Message

    # pong message
    # https://bitcoin.org/en/developer-reference#pong
    class Pong < Base

      COMMAND = 'pong'

      attr_reader :nonce

      def initialize(nonce)
        @nonce = nonce
      end

      def to_payload
        [nonce].pack('Q')
      end
    end

  end
end