require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "date"
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

  case params[:payment_type]
  when "cc_credit" then redirect "/cc_credit"
  when "flat_rate" then redirect "/flat_rate"
  when "hourly_rate" then redirect "/hourly_rate"
  end
end

post "/cc_credit" do
  session[:cc_credits] = params[:cc_credits]
  
  session[:flat_rate] = 'Yes'
  session[:hourly_rate] = 0.00
  session[:hours] = 0.00

  session[:amount] = "%.2f" % (session[:cc_credits].to_f * 50.00)

  redirect "/data_verification"
end

post "/flat_rate" do
  session[:flat_rate] = params[:flat_rate]

  session[:cc_credits] = 'N/A'
  session[:hourly_rate] = 0.00
  session[:hours] = 0.00

  session[:amount] = "%.2f" % session[:flat_rate].to_f

  redirect "/data_verification"
end

post "/hourly_rate" do
  session[:hourly_rate] = params[:hourly_rate]
  session[:hours] = params[:hours]

  session[:cc_credits] = 'N/A'
  session[:flat_rate] = 'No'

  session[:amount] = "%.2f" % (session[:hourly_rate].to_f * session[:hours].to_f)

  redirect "/data_verification"
end

post "/input_verified_data" do
  if params[:yes]
    article_name = session[:article_name]
    url = session[:url]
    date_published = "#{session[:day]}/#{session[:month]}/#{session[:year]}"
    word_count = session[:word_count]
    cc_credit = session[:cc_credits]
    flat_rate = session[:flat_rate]
    hours = session[:hours]
    hourly_rate = session[:hourly_rate]
    amount = session[:amount]

    @storage.add_article_to_timesheet_database(article_name, url, date_published, word_count, cc_credit, flat_rate, hours, hourly_rate, amount)

    session[:message] = "Data was successfully added to the timesheet database."
    
    redirect "/timesheet"
  else
    redirect "/input_time"
  end
end
