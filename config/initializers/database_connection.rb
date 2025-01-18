Rails.application.config.after_initialize do
  ActiveRecord::Base.connection_pool.disconnect!

  ActiveSupport.on_load(:active_record) do
    database_url = ENV['DATABASE_URL']
    if database_url
      pool_size = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
      
      db_config = ActiveRecord::Base.connection_pool.db_config
      connection_options = db_config.configuration_hash.merge(pool: pool_size)
      
      ActiveRecord::Base.establish_connection(connection_options)

      # Log database connection info
      Rails.logger.info "Database Connection Pool Size: #{ActiveRecord::Base.connection.pool.size}"
      Rails.logger.info "Database Connection Pool Checkout Timeout: #{ActiveRecord::Base.connection.pool.checkout_timeout}"
    end
  end

  if defined?(PhusionPassenger)
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      if forked
        ActiveRecord::Base.establish_connection
      end
    end
  end

  if defined?(Puma)
    Puma.cli_config.options.fetch(:max_threads, 5).times do
      ActiveRecord::Base.connection_pool.checkout
    end
  end
end
