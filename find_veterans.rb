require 'httparty'

class FindVeterans
  include HTTParty
  base_uri 'https://api.github.com'

  # Find the first 10 users on GitHub whose location starts with "New York"
  def initialize
    @top_ten = []
    new_yorkers = self.class.get("/search/users\?q\=type:user+location:New-York").parsed_response["items"]
    new_yorkers.map.with_index { |user, i| @top_ten << [user["login"]] if i < 10 }
  end

  # Get the names and locations of these first 10 users
  def get_name_and_location
    @top_ten.each do |user|
      user_details = self.class.get("/users/#{user[0]}").parsed_response
      user << user_details["name"]
      user << user_details["location"]
    end
  end

  # Get a count of their public repositories created since the beginning of the day January 1 of 2015 (UTC)
  def count_public_repos
    @top_ten.each do |user|
      public_repos = self.class.get("/users/#{user[0]}/repos?q=visibility:public+created:\>\=2015-01-01T00:00:00-07:00").parsed_response
      user << public_repos.length
    end
  end

  # Generate a CSV file with the following headers: login, name, location, repo count
  def generate_CSV
    CSV.open("./veterans.csv", "w", 
              write_headers: true,
              headers: ["login", "name", "location", "repo count"]
            ) do |csv|
      @top_ten.each { |row| csv << row }
    end
  end
end

# Driver Code
veteran_finder = FindVeterans.new
veteran_finder.get_name_and_location
veteran_finder.count_public_repos
veteran_finder.generate_CSV
puts "See veterans.csv for the final output!"
