module IrcBot
  class Application < Sinatra::Base
    helpers do

      def html_requested?
        params[:format] != 'json' && env['rack-accept.request'].media_type?( 'text/html' )
      end

    end
  end
end
