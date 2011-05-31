class Link
  include DataMapper::Resource

  property :long_url,   String, :length => 1024, :format => :url
  property :short_url,  String, :key => true
  property :created_at, DateTime

  def self.gen_short_url
    # Create an Array of possible characters
    chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
    tmp = chars[rand(62)] + chars[rand(62)] + chars[rand(62)]

    while Link.get(tmp)
      puts "Tried " + tmp
      tmp = chars[rand(62)] + chars[rand(62)] + chars[rand(62)]
      puts "tmp is now " + tmp
    end

    tmp
  end
end
