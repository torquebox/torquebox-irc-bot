require 'rubygems'
require 'bundler/setup'
require 'irc_bot'

extend TorqueBox::Injectors
inject('service:irc_bot_service')

map '/health' do
  health = proc do |env|
    [200, { "Content-Type" => "text/html" }, ["1"]]
  end
  run health
end

map '/' do
  run IrcBot::Application
end
