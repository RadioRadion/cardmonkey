if defined?(Puma)
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
