require 'torquebox-stomp'

class IrcStomplet < TorqueBox::Stomp::JmsStomplet

  def initialize()
    super
  end

  def configure(stomplet_config)
    super
    @destination      = stomplet_config['destination']
    @destination_type = stomplet_config['type']
  end

  def on_message(stomp_message, session)
    send_to( stomp_message, @destination, @destination_type )
  end

  def on_subscribe(subscriber)
    subscribe_to( subscriber, @destination, @destination_type )
    announcement = org.projectodd.stilts.stomp::StompMessages.createStompMessage( @destination, "[#{Time.now.ctime}] TorqueBox bot in da house!" )
    send_to( announcement, @destination, @destination_type )
  end

end

