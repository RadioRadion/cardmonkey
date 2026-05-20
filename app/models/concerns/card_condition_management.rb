# app/models/concerns/card_condition_management.rb
module CardConditionManagement
  extend ActiveSupport::Concern

  CONDITION_ORDER = %w[poor played light_played good excellent near_mint mint].freeze

  included do
    def condition_value(condition_name)
      CONDITION_ORDER.index(condition_name.to_s)
    end

    def meets_condition_requirement?(required_condition)
      return true if required_condition == 'unimportant'
      condition_value(condition) >= condition_value(required_condition)
    end
  end
end
