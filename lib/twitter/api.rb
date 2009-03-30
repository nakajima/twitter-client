module Twitter
  # Namespace for constants and exceptions related to the Twitter API.
  module API
    # Everything goes to Twitter for now
    BASE = 'twitter.com'

    # Everything goes through JSON for now
    FORMAT = 'json'

    # Raised when API returns a 401 response status.
    class Unauthorized < StandardError ; end
  end
end
