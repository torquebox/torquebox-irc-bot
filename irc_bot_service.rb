require 'ponder'

class IrcBotService
  def initialize(options={})
    @nick = options['nick']
    @server = options['server']
    @port = options['port']
    @channel = options['channel']

    @messages = []
  end

  def start
    @bot = configure_bot
    # Start the IRC bot in a separate thread
    @bot_thread = Thread.new { @bot.connect }
  end

  def stop
    # Disconnect from IRC
    @bot.quit
    # Wait for the spawned thread to exit
    @bot_thread.join
  end

  def new_messages(since)
    @messages.select { |message| message['time'] > since }
  end

  protected

  def configure_bot
    bot = Ponder::Thaum.new
    bot.configure do |c|
      c.nick = @nick
      c.server = @server
      c.port = @port
    end

    # Join requested channel
    bot.on :connect do
      bot.join @channel
    end

    # Log all channel messages to the queue
    bot.on :channel do |event_data|
      @messages << {
        'time' => Time.now,
        'nick' => event_data[:nick],
        'text' => event_data[:message]
      }
      @messages.slice!(0) if @messages.length > 100
    end

    bot
  end

end
