module Twitter
  module API
    BASE = 'twitter.com'
    FORMAT = 'json'
    
    class Unauthorized < StandardError ; end
  end
end