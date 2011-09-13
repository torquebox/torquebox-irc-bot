class IrcController < ApplicationController
  include TorqueBox::Injectors

  respond_to :html, :json

  def index
    # We want all IRC messages since the last one we saw
    # or since now if this is a new connection
    since = session[:last_seen] || Time.now

    # Ask the IRC bot for all new messages
    service = inject('service:irc_bot_service')
    messages = service.new_messages(since)

    # Update the timestamp of the last seen message
    session[:last_seen] = messages.blank? ? since : messages.last['time']

    # Convert each message from a hash into a text string for display
    @formatted_messages = messages.map do |message|
      "#{message['time'].to_s(:short)} #{message['nick']}: #{message['text']}"
    end
    respond_with(@formatted_messages)
  end

end
