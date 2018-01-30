module Browserlog
  class LogReader
    # def read(options = {})
    #   @log_file_name = options[:log_file_name] || 'development'
    #   offset = options[:offset] || -1
    #   limit = options[:limit] || 25
    #   amount = [limit, remaining_lines(offset)].min

    #   line_index = offset == -1 ? num_lines : offset + amount

    #   [readlines(amount), line_index]
    # end

    def read(options = {})
      @log_file_name = options[:log_file_name] || 'development'
      limit = 25
      [readlines(limit), limit]
    end

    private

    def log_path
      Rails.root.join("log/#{@log_file_name}.log")
    end

    def readlines(amount)
      `tail -n #{amount} #{log_path}`.split(/\n/)
    end
  end
end
