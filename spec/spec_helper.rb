$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bitcoin'
require 'logger'
require 'timecop'

RSpec.configure do |config|
  config.before(:each) do |example|
    if example.metadata[:network]
      Bitcoin.chain_params = example.metadata[:network]
    else
      Bitcoin.chain_params = :testnet
    end
    if example.metadata[:use_secp256k1]
      use_secp256k1
    else
      use_ecdsa_gem
    end
  end
end

def use_secp256k1
  host_os = RbConfig::CONFIG['host_os']
  case host_os
    when /darwin|mac os/
      ENV['SECP256K1_LIB_PATH'] = File.expand_path('lib/libsecp256k1.dylib', File.dirname(__FILE__))
    when /linux/
      ENV['SECP256K1_LIB_PATH'] = File.expand_path('lib/libsecp256k1.so', File.dirname(__FILE__))
    else
      raise "#{host_os} is an unsupported os."
  end
end

def use_ecdsa_gem
  ENV['SECP256K1_LIB_PATH'] = nil
end

def fixture_file(relative_path)
  file = File.read(File.join(File.dirname(__FILE__), 'fixtures', relative_path))
  JSON.parse(file)
end

def load_block(hash)
  File.read(File.join(File.dirname(__FILE__), 'fixtures', "block/#{hash}"))
end

TEST_DB_PATH = Dir.tmpdir + '/spv'

def create_test_chain
  FileUtils.rm_r(TEST_DB_PATH) if Dir.exist?(TEST_DB_PATH)
  Bitcoin::Store::SPVChain.new(Bitcoin::Store::DB::LevelDB.new(TEST_DB_PATH))
end

TEST_WALLET_PATH = Dir.tmpdir + '/wallet/'

def test_wallet_path(wallet_id = 1)
  "#{TEST_WALLET_PATH}wallet#{wallet_id}/"
end

def create_test_wallet(wallet_id = 1)
  path = test_wallet_path(wallet_id)
  FileUtils.rm_r(path) if Dir.exist?(path)
  Bitcoin::Wallet::Base.create(wallet_id, TEST_WALLET_PATH)
end

module Bitcoin
  autoload :TestScriptParser, 'bitcoin/script/test_script_parser'
end

RSpec::Matchers.define :custom_object do |clazz, properties|
  match do |actual|
    return false unless actual.is_a?(clazz)
    properties.each do |key, value|
      return false unless actual.send(key) == value
    end
    true
  end
end