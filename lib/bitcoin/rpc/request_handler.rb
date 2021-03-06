module Bitcoin
  module RPC

    # RPC server's request handler.
    module RequestHandler

      # Returns an object containing various state info regarding blockchain processing.
      def getblockchaininfo
        h = {}
        h[:chain] = Bitcoin.chain_params.network
        best_block = node.chain.latest_block
        h[:headers] = best_block.height
        h[:bestblockhash] = best_block.hash
        h[:chainwork] = best_block.header.work
        h[:mediantime] = node.chain.mtp(best_block.hash)
        h
      end

      # shutdown node
      def stop
        node.shutdown
      end

      # get block header information.
      def getblockheader(hash, verbose)
        entry = node.chain.find_entry_by_hash(hash)
        if verbose
          {
              hash: hash,
              height: entry.height,
              version: entry.header.version,
              versionHex: entry.header.version.to_s(16),
              merkleroot: entry.header.merkle_root,
              time: entry.header.time,
              mediantime: node.chain.mtp(hash),
              nonce: entry.header.nonce,
              bits: entry.header.bits.to_s(16),
              previousblockhash: entry.prev_hash,
              nextblockhash: node.chain.next_hash(hash)
          }
        else
          entry.header.to_payload.bth
        end
      end

      # Returns connected peer information.
      def getpeerinfo
        node.pool.peers.map do |peer|
          local_addr = peer.remote_version.remote_addr[0..peer.remote_version.remote_addr.rindex(':')] + '18333'
          {
            id: peer.id,
            addr: "#{peer.host}:#{peer.port}",
            addrlocal: local_addr,
            services: peer.remote_version.services.to_s(16).rjust(16, '0'),
            relaytxes: peer.remote_version.relay,
            lastsend: peer.last_send,
            lastrecv: peer.last_recv,
            bytessent: peer.bytes_sent,
            bytesrecv: peer.bytes_recv,
            conntime: peer.conn_time,
            pingtime: peer.ping_time,
            minping: peer.min_ping,
            version: peer.remote_version.version,
            subver: peer.remote_version.user_agent,
            inbound: !peer.outbound?,
            startingheight: peer.remote_version.start_height,
            best_hash: peer.best_hash,
            best_height: peer.best_height
          }
        end
      end

      # broadcast transaction
      def sendrawtransaction(hex_tx)
        tx = Bitcoin::Tx.parse_from_payload(hex_tx.htb)
        # TODO check wether tx is valid
        node.broadcast(tx)
        tx.txid
      end

      # wallet api

      # create wallet
      def createwallet(wallet_id = 1, wallet_path_prefix = Bitcoin::Wallet::Base::DEFAULT_PATH_PREFIX)
        wallet = Bitcoin::Wallet::Base.create(wallet_id, wallet_path_prefix)
        node.wallet = wallet unless node.wallet
        {wallet_id: wallet.wallet_id, mnemonic: wallet.master_key.mnemonic}
      end

      # get wallet list.
      def listwallets(wallet_path_prefix = Bitcoin::Wallet::Base::DEFAULT_PATH_PREFIX)
        Bitcoin::Wallet::Base.wallet_paths(wallet_path_prefix)
      end

      # get current wallet information.
      def getwalletinfo
        return {} unless node.wallet
        {wallet_id: node.wallet.wallet_id, version: node.wallet.version}
      end

    end

  end
end
