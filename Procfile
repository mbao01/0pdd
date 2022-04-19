process :zero_pdd do

  # Only action this process in production on a specific host
  # constraint :environment => 'production', :host => 'app01.myapp.com'

  # Only action this process in development
  # constraint :environment => 'development'

  # Define the action to be carried out when this process should start
  start do
    system("bundle exec rackup config.ru -p 4567 &> /opt/0pdd.log &")
  end

  # Define the action to be carried out when this process should stop
  stop do
    system("kill -9 $(lsof -t -i:4567)")
  end

  # Define the action to be carried out when this process should restart
  restart { stop and start }

end
