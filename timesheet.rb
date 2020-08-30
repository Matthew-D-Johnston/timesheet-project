require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "pry"

require_relative "database_persistence"

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

before do
  @storage = DatabasePersistence.new
end

after do
  @storage.disconnect
end

get "/" do
  redirect "/timesheet"
end

get "/timesheet" do
  erb :timesheet_welcome
end

get "/input_time" do
  erb :time_input
end

get "/cc_credit" do
  erb :cc_credit
end

get "/flat_rate" do
  erb :flat_rate
end

get "/hourly_rate" do
  erb :hourly_rate
end

get "/data_verification" do
  erb :data_verification
end

get "/create_invoice" do

end

get "/create_report" do

end

post "/time_input" do
  session[:article_name] = params[:article_name]
  session[:url] = params[:url]
  session[:word_count] = params[:word_count]

  session[:day] = params[:day]
  session[:month] = params[:month]
  session[:year] = params[:year]

  if params[:cc_credit]
    redirect "/cc_credit"
  elsif params[:flat_rate]
    redirect "/flat_rate"
  else
    redirect "/hourly_rate"
  end
end

post "/cc_credit" do
  session[:cc_credits] = params[:credits]

  redirect "/data_verification"
end

post "/flat_rate" do
  session[:flat_rate] = params[:flat_rate]

  redirect "/data_verification"
end

post "/hourly_rate" do
  session[:hourly_rate] = params[:hourly_rate]
  session[:hours] = params[:hours]

  redirect "/data_verification"
end
