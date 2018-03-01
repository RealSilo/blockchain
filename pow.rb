require 'digest'

LEADING_ZEROS = 5

def hash(message)
  Digest::SHA256.hexdigest(message)
end

def find_nonce(message)
  nonce = 0

  until valid_nonce?(nonce, message)
    print '.' if nonce % 10_000 == 0
    nonce += 1
  end

  puts
  puts "Hash: #{hash([message, nonce.to_s].join())}"
  nonce
end

def valid_nonce?(nonce, message)
  hash([message, nonce.to_s].join()).start_with?('0' * LEADING_ZEROS)
end

message = 'My blockchain transaction'
puts("Nonce: #{find_nonce(message)}")
