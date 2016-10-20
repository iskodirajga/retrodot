class Message < ActiveRecord::Base

  class << self
    def process_message(user, message)
      result = ChatOps.process(user, message[:text])

      parse_result(result)
    end

    private

    def parse_result(result)
      result = if result
        result[:reaction] ? result[:reaction] : result[:message]
      else
        "command unknown, try `/timeline help`"
      end

      result
    end

  end
end
