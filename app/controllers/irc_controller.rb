class IrcController < ApplicationController
  respond_to :html

  def index
    render :template => 'irc/index'
  end

end
