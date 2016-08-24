module Helpers
  module Paginator
    class << self
      def fetch(url)
        @url = url
        data  = []
        page = 1

        while true
          response  = Excon.get(endpoint_for(page))
          data <<  JSON.parse(response.body)

          if (next_page = next_in(response)) > page
            page = next_page
          else
            break
          end
        end

        data.flatten
      end

      private
      def endpoint_for(page)
        "#{@url}?per_page=100&page=#{page}"
      end

      def next_in(response)
        response.headers['Link'].split(',').last.match(/<.+[?|&]page=(\d+).*>/)[1].to_i
      end

    end
  end
end
