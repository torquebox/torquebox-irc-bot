require 'torquebox-messaging'

class IrcStomplet < TorqueBox::Stomp::JmsStomplet
  include TorqueBox::Messaging

  def initialize()
    super
  end

  def configure(config)
    super
    @destination = Queue.new( config['destination'] )
  end

  def on_subscribe(subscriber)
    subscribe_to( subscriber, @destination )
    send_to( @destination, "TorqueBoxBot in da house", :sender => :system, :timestamp => Time.now.ctime )
  end

end

