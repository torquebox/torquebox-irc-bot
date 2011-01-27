TorqueboxIrcBot::Application.routes.draw do
  resource :irc
  root :to => "irc#index"
end
