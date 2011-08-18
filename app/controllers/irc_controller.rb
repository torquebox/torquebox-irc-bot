class IrcController < ApplicationController
  include TorqueBox::Injectors
  respond_to :html

  def index
    render :template => 'irc/index'
  end

end
