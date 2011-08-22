require 'torquebox-stomp'

class IrcStomplet < TorqueBox::Stomp::JmsStomplet
  include TorqueBox::Injectors

  def initialize()
    super
  end

  def configure(config)
    super
    @destination = inject(config['destination'])
  end

  def on_subscribe(subscriber)
    subscribe_to( subscriber, @destination )
    send_to( @destination, "TorqueBoxBot in da house", :sender => :system, :timestamp => Time.now.ctime )
  end

end

