class IrcBotService
  include TorqueBox::Injectors
  
  def initialize(options={})
    @nick        = options['nick']
    @server      = options['server']
    @port        = options['port']
    @channel     = options['channel']
    @destination = options['destination']
  end

  def start
    @bot = configure_bot
    # Start the IRC bot and queue in separate threads
    @bot_thread = Thread.new { @bot.connect }
  end

  def stop
    # Disconnect from IRC
    @bot.quit
    # Notify our queue receiver to stop
    @done = true
    # Wait for all spawned threads to exit
    @bot_thread.join
  end

  protected

  def configure_bot
    bot = Ponder::Thaum.new
    bot.configure do |c|
      c.nick   = @nick
      c.server = @server
      c.port   = @port
    end

    # Join requested channel
    bot.on :connect do
      bot.join @channel
    end

    # Log all channel messages to the queue
    queue = inject('/queues/irc_messages')
    bot.on :channel do |event_data|
      text = "[#{Time.now.ctime}] #{event_data[:nick]}: #{event_data[:message]}"
      message = org.projectodd.stilts.stomp::StompMessages.createStompMessage( @destination, text )
      queue.publish( message.content_as_string )
    end

    bot
  end
end
