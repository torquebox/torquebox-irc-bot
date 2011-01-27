class IrcBotService
  def initialize(options={})
    @nick = options['nick']
    @server = options['server']
    @port = options['port']
    @channel = options['channel']

    @messages = []
    @halt = false
  end

  def start
    @bot = configure_bot
    # Start the IRC bot and queue in separate threads
    @bot_thread = Thread.new { @bot.connect }
    @queue_thread = Thread.new { start_queue }
  end

  def stop
    # Disconnect from IRC
    @bot.quit
    # Notify our queue receiver to stop
    @halt = true
    # Wait for all spawned threads to exit
    @queue_thread.join
    @bot_thread.join
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
        :time => Time.now,
        :nick => event_data[:nick],
        :text => event_data[:message]
      }
      @messages.slice!(0) if @messages.length > 100
    end

    # Respond to everything with "kk"
    # @bot.on :channel, /^#{@nick}:/ do |event_data|
    #   @bot.message event_data[:channel], "#{event_data[:nick]}: kk"
    # end
    bot
  end

  def start_queue
    queue = TorqueBox::Messaging::Queue.new('/queues/irc_messages')
    queue.start

    while true do
      request = queue.receive(:timeout => 500, :decode => false)
      handle_request(request) unless request.nil?

      # Jump out of the loop if we're shutting down
      if @halt
        queue.destroy
        break
      end
    end
  end

  def handle_request(request)
    reply = request.getJMSReplyTo
    payload = request.decode
    response = @messages.select { |message| message[:time] > payload[:since] }
    TorqueBox::Messaging::Client.connect do |session|
      session.publish(reply, response)
      session.commit if session.transacted?
    end
  end

end
