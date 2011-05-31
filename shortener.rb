require 'rubygems'
require 'sinatra'
require 'datamapper'
require 'haml'
require 'rack-flash'

# Require Models
Dir.glob("#{Dir.pwd}/models/*.rb") { |m| require "#{m.chomp}" }

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/database.db")

use Rack::Flash
enable :sessions
set :haml, :format => :html5 # default for Haml format is :xhtml

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

  if @link.save
    status 201 # Link saved successfully
    redirect '/url/' + @link.short_url
  else
    flash[:error]="Please enter a valid URL."
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
    redirect '/url/' + @link.short_url
  else
    flash[:error]="Please enter a valid URL."
    status 400 # Bad Request
    haml :index
  end
end

# Finalize/initialize DB
DataMapper.finalize
DataMapper::auto_upgrade!
