class IrcController < ApplicationController
  respond_to :html, :json

  def index
    # queue = TorqueBox::Messaging::Queue.new('/queues/irc_messages')
    # queue.publish('donkey kong')
    # queue.send_and_receive(...)
    since = session[:last_seen] || Time.now
    messages = nil
    TorqueBox::Messaging::Client.connect do |session|
      messages = session.send_and_receive('/queues/irc_messages',
                                          {:since => since},
                                          :timeout => 2000)
      session.commit if session.transacted?
    end
    session[:last_seen] = messages.blank? ? since : messages.last[:time]
    messages ||= []
    @formatted_messages = messages.map do |message|
      "#{message[:time].to_s(:short)} #{message[:nick]}: #{message[:text]}"
    end
    respond_with(@formatted_messages)
  end

end
