require 'torquebox-messaging'

class IrcBotService
  include TorqueBox::Messaging
  
  def initialize(options={})
    @nick        = options['nick']
    @server      = options['server']
    @port        = options['port']
    @channel     = options['channel']
    @destination = Queue.new( options['destination'] )
  end

  def start
    @bot = configure_bot
    # Start the IRC bot and queue in separate threads
    @bot_thread = Thread.new { @bot.connect }
  end

  def stop
    # Disconnect from IRC
    @bot.quit
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
    bot.on :channel do |event_data|
      @destination.publish( event_data[:message], :properties => {:sender=>event_data[:nick], :timestamp=>Time.now.ctime} )
    end

    bot
  end
end
