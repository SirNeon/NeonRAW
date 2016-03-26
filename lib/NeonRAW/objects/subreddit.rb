module NeonRAW
  class Subreddit
    attr_reader :data
    def initialize(name)
      @data = request_data("/r/#{name}/about.json")[:data]
    end
  end
end
