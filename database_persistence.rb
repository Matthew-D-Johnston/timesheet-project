require "pg"

class DatabasePersistence
  def initialize
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "investopedia_timesheet")
          end
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def add_article_to_timesheet_database(article_name, url, date_published, word_count, cc_credit, flat_rate, hours, hourly_rate, amount)
    sql = <<~SQL
      INSERT INTO timesheet (article_name, url, date_published, word_count, cc_credit, flat_rate, hours, hourly_rate, amount)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
    SQL

    query(sql, article_name, url, date_published, word_count, cc_credit, flat_rate, hours, hourly_rate, amount)
  end

  def find_invoice_data(month)
    sql = <<~SQL
      SELECT article_name, url, hourly_rate, hours, amount FROM timesheet
       WHERE cc_credit = 'N/A' AND date_part('month', date_published) = $1
    SQL

    query(sql, month)
  end

  def find_invoice_total_amount(month)
    sql = <<~SQL
      SELECT sum(amount) AS total_amount FROM timesheet
       WHERE cc_credit = 'N/A' AND date_part('month', date_published) = $1
    SQL

    result = query(sql, month)

    result[0]["total_amount"]
  end
end
