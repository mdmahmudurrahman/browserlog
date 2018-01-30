module Browserlog
  class LogsController < ActionController::Base
    before_action :current_environment
    before_action :check_env
    before_action :check_auth

    layout 'browserlog/application'

    # require 'pry'
    def index
      @filename = "#{@env}.log"
      @filepath = Rails.root.join("log/#{@filename}")
    end

    def changes
      lines, last_line_number = reader.read(offset: params[:currentLine].to_i, log_file_name: @env)
      respond_to do |format|
        format.json do
          render json: {
            lines: lines.map! { |line|
              colorizer.colorize_line(format_log(line))
            },
            last_line_number: last_line_number
          }
        end
      end
    end

    private

    def reader
      Browserlog::LogReader.new
    end

    def colorizer
      Browserlog::LogColorize.new
    end

    def check_env
      unless Browserlog.config.allowed_log_files.include?(@env)
        Rails.logger.info("###################################")
        Rails.logger.info("########Log file doesn't exist#####")
        Rails.logger.info("###################################")
        raise
      end
    end

    def check_auth
      if(@env == "production" && !Browserlog.config.allow_production_logs)
        Rails.logger.info("#######################################################")
        Rails.logger.info("######Logs not allowed on production environment.######")
        Rails.logger.info("#######################################################")
        raise
      end
    end

    def current_environment
      @env = Rails.env
    end

    def format_log line
      if(@env == "staging" || @env == "production")
        if !(/^D/ =~ line).nil?
          line.split(/DEBUG\s\--\s\:\s/)[1].strip unless line.split(/DEBUG\s\--\s\:\s/).empty?
        elsif !(/^I/ =~ line).nil?
          line.split(/INFO\s\--\s\:\s/)[1].strip unless line.split(/INFO\s\--\s\:\s/).empty?
        end
      else
        line
      end
    end
  end
end
