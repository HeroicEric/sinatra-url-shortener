require 'rubygems'
require 'sinatra'
require 'datamapper'
require 'haml'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/bijou.db")

set :haml, :format => :html5 # default for Haml format is :xhtml

class Link
  include DataMapper::Resource

  property :long_url,   String
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

  def bijou
    "<a href='/#{short_url}'>Bijou!</a>"
  end
end

get '/' do
  haml :index
end

get '/:short_url' do
  @link = Link.get(params[:short_url])

  redirect "#{@link.long_url}"
end

# Create a new Link with a Short URL!
post '/url' do
  @link = Link.new(:long_url => params[:url], :short_url => Link.gen_short_url)
  puts @link.long_url + " can b reached at " + @link.short_url

  if @link.save
    status 201 # Link saved successfully
    redirect "/url/#{@link.short_url}"
  else
    status 400 # Bad Request
    haml :index
  end
end

get '/url/:short_url' do
  @link = Link.get(params[:short_url])

  haml :link
end

# Create a new Link using capture params and regular expressions
get %r{/new/(.+)} do
  @link = Link.new(:long_url => params[:captures], :short_url => Link.gen_short_url)

  if @link.save
    status 201 # Link saved successfully
    redirect "/url/#{@link.short_url}"
  else
    status 400 # Bad Request
    haml :index
  end
end

# Finalize/initialize DB
DataMapper.finalize
DataMapper::auto_upgrade!
