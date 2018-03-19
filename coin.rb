require 'sinatra'
require 'colorize'
require_relative 'block_chain'
require_relative 'client'
require_relative 'helpers'

configure { set :server, :puma }

PORT, PEER_PORT = ARGV.first(2)
set :port, PORT

BALANCES = {
  'silo' => 1_000_000,
}


# @param user
get '/balance' do
  user = params['user']
  puts BALANCES.to_s.yellow
  "#{user} has #{BALANCES[user]}"
end

# @param name 
post '/users' do
  name = params['name']
  BALANCES[name] ||= 0
  'OK'
end

# @param from
# @param to
# @param amount
post '/transfers' do
  from, to = params.values_at('from', 'to').map(&:downcase)
  amount = params['amount'].to_i
  raise unless BALANCES[from] >= amount
  BALANCES[from] -= amount
  BALANCES[to] += amount
  'OK'
end
