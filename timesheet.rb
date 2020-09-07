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

def create_invoice_number(number)
  number = number.to_i

  "%04d" % number
end

def add_commas_to_numeric_amounts(number)
  case number.length
  when (0..6) then number
  when (7..9) then number.insert(-7, ',')
  when (10..12) then number.insert(-10, ',').insert(-7, ',')
  end
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
  erb :create_invoice
end

get "/create_report" do
  erb :create_report
end

get "/invoice" do
  time = Time.now
  day = "%02d" % time.day
  month = "%02d" % time.month
  year = time.year

  @current_date = "#{month}/#{day}/#{year}"
  @invoice_number = create_invoice_number(session[:invoice_number])

  @article_data = @storage.find_invoice_data(session[:invoice_month], session[:invoice_year])
  @article_total_amount = @storage.find_invoice_total_amount(session[:invoice_month], session[:invoice_year])
  @article_total_amount = add_commas_to_numeric_amounts(@article_total_amount)
  
  erb :invoice
end

get "/monthly_report" do
  @month_name = Date::MONTHNAMES[session[:report_month].to_i]

  erb :monthly_report
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
    date_published = "#{session[:month]}/#{session[:day]}/#{session[:year]}"
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

post "/create_invoice" do
  session[:invoice_number] = params[:invoice_number]
  session[:invoice_year] = params[:invoice_year]
  session[:invoice_month] = params[:invoice_month]

  redirect "/invoice"
end

post "/create_report" do
  session[:report_year] = params[:report_year]
  session[:report_month] = params[:report_month]

  redirect "/monthly_report"
end
