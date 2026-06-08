module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: :create
    before_action :configure_account_update_params, only: :update

    private

    # Address is collected at sign up so geocoding can run (matching is
    # distance-based: without coordinates a new user sees no opportunities).
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[username address])
    end

    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: %i[username address])
    end
  end
end
