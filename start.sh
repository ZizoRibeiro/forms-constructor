# Install Gems
bundle check || bundle install
# Start server
bundle exec puma -C config/puma.rb