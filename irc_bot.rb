require 'sinatra/base'
require 'rack/accept'
require 'json'


$:.unshift File.join( File.dirname( __FILE__ ), 'lib' )

require 'helpers'

module IrcBot
  class Application < Sinatra::Base
    include TorqueBox::Injectors
    enable :sessions
    use Rack::Accept

    get '/' do
      # We want all IRC messages since the last one we saw
      # or since now if this is a new connection
      since = session[:last_seen] || Time.now

      # Ask the IRC bot for all new messages
      service = inject('service:irc_bot_service')
      messages = service.new_messages(since)

      # Update the timestamp of the last seen message
      session[:last_seen] = messages.empty? ? since : messages.last['time']

      # Convert each message from a hash into a text string for display
      @formatted_messages = messages.map do |message|
        "#{message['time'].to_s} #{message['nick']}: #{message['text']}"
      end

      if html_requested?
        haml :index
      else
        content_type :json
        @formatted_messages.to_json
      end
    end
  end
end
