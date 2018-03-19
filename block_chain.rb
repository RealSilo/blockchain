require 'colorize'
require 'digest'


class Block
  LEADING_ZEROS = 5 
  attr_reader :block_hash, :msg, :prev_block_hash
  
  def initialize(prev_block, msg)
    @msg = msg
    @prev_block_hash = prev_block.block_hash if prev_block
    mine_block!
  end

  def self.create_genesis_block(msg)
    Block.new(nil, msg)
  end

  def mine_block!
    @nonce = find_nonce
    @block_hash = hash(block_contents + @nonce.to_s)
  end

  def valid?
    valid_nonce?(@nonce)
  end

  private

  def block_contents
    [@prev_block_hash, @msg].compact.join
  end

  def hash(message)
    Digest::SHA256.hexdigest(message.to_s)
  end

  def find_nonce
    nonce = 0

    until valid_nonce?(nonce)
      print '.' if nonce % 10_000 == 0
      nonce += 1
    end
    puts nonce

    nonce
  end

  def valid_nonce?(nonce)
    hash(block_contents + nonce.to_s).start_with?('0' * LEADING_ZEROS)
  end

  def to_s
    [
      "",
      "-" * 80,
      "Previous hash: ".rjust(15) + @prev_block_hash.to_s.yellow,
      "Message: ".rjust(15) + @msg.green,
      "Nonce: ".rjust(15) + @nonce.to_s.red,
      "Own hash: ".rjust(15) + @block_hash.yellow,
      "-" * 80,
      "|".rjust(40),
      "|".rjust(40),
      "v".rjust(40)
    ].join("\n")
  end
end

class BlockChain
  attr_reader :blocks

  def initialize(msg)
    @blocks = [Block.create_genesis_block(msg)]
  end

  def push(msg)
    @blocks << Block.new(@blocks.last, msg)
    puts @blocks.last
  end

  def valid?
    @blocks.all? { |block| block.is_a?(Block) } &&
    # check if all the blocks are valid
    # recalculated block hashes (block_hash) == next_block.prev_block_hash
    @blocks.all?(&:valid?) &&
    # check if ordering has not been changed
    @blocks.each_cons(2).all? { |a, b| a.block_hash == b.prev_block_hash }
  end

  def to_s
    @blocks.map(&:to_s).join("\n")
  end
end

block_chain = BlockChain.new('genesis block')
block_chain.push('hi')
block_chain.push('cool dude')
puts block_chain.valid?
