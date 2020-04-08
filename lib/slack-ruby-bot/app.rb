# frozen_string_literal: true

module SlackRubyBot
  class App < Server
    def initialize(options = {})
      server_options = { token: options[:token] }
      super(server_options)
    end

    def config
      SlackRubyBot.config
    end

    def self.instance
      @instance ||= begin
        configure!
        new(token: SlackRubyBot.config.token)
      end
    end

    private

    def self.configure!
      SlackRubyBot.configure do |config|
        config.token = ENV['SLACK_API_TOKEN'] if ENV.key?('SLACK_API_TOKEN')
        raise("Missing ENV['SLACK_API_TOKEN'].") if config.token.nil?

        config.aliases = ENV['SLACK_RUBY_BOT_ALIASES'].split(' ') if ENV['SLACK_RUBY_BOT_ALIASES']
      end
      Slack.configure do |config|
        config.token = SlackRubyBot.config.token
      end
    end
    private_class_method :configure!

    def hello(client, _data)
      if client.team && client.self
        SlackRubyBot.configure do |config|
          config.url = "https://#{client.team.domain}.slack.com"
          config.team = client.team.name
          config.team_id = client.team.id
          config.user = client.self.name
          config.user_id = client.self.id
          logger.info "Welcome #{config.user} to the #{config.team} team."
        end
      end
      super
    end

    def reset!
      super
      SlackRubyBot.configure do |config|
        config.url = nil
        config.team = nil
        config.user = nil
        config.team_id = nil
        config.user_id = nil
      end
    end
  end
end
