Rails.application.config.after_initialize do
  ActiveRecord::Base.connection_pool.with_connection do |connection|
    begin
      retries ||= 0
      connection.verify!
    rescue ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad => e
      if (retries += 1) <= 5
        Rails.logger.warn "Database connection failed! Retry attempt #{retries} of 5"
        sleep(retries * 2) # Exponential backoff
        retry
      else
        Rails.logger.error "Database connection failed after 5 attempts! Error: #{e.message}"
        raise
      end
    end
  end
end
