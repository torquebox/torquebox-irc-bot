# This file is used by Rack-based servers to start the application.
require 'torquebox-stomp'
require ::File.expand_path('../config/environment',  __FILE__)
use TorqueBox::Stomp::StompJavascriptClientProvider
run TorqueboxIrcBot::Application
