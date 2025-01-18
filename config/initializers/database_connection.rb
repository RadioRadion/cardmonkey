Rails.application.config.after_initialize do
  ActiveRecord::Base.connection_pool.disconnect!

  ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first
    config.pool = ENV['RAILS_MAX_THREADS'] || 5
    
    ActiveRecord::Base.establish_connection

    # Log database connection info
    Rails.logger.info "Database Connection Pool Size: #{ActiveRecord::Base.connection.pool.size}"
    Rails.logger.info "Database Connection Pool Checkout Timeout: #{ActiveRecord::Base.connection.pool.checkout_timeout}"
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
