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
end
