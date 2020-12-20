require "bundler/setup"
require 'sinatra'
require 'sinatra/json'
require 'local_playlist'
require 'pry'

LocalPlaylist.configure do |config|
  config.sk_key  = ENV.fetch('SK_API_KEY')
end
set :root, File.dirname(__FILE__)


get '/' do
  erb :index
end

get '/lq/:coords' do
  cache_file = File.join(root,"cache", "#{params[:coords]}.json")
  if !File.exist?(cache_file) || (File.mtime(cache_file) < (Time.now - 3600*24*5))
    data = json(LocalPlaylist::Venues.new(coordinates: params[:coords]).list)
    File.open(cache_file,"w"){ |f| f << data }
  end
  send_file cache_file, :type => 'application/json'
end
