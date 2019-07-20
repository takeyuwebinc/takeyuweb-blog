class ApplicationController < ActionController::Base
  private

  def authenticate
    basic_auth = Rails.application.credentials.basic_auth
    authenticate_or_request_with_http_basic do |name, password|
      # This comparison uses & so that it doesn't short circuit and
      # uses `secure_compare` so that length information
      # isn't leaked.
      ActiveSupport::SecurityUtils.secure_compare(name, basic_auth[:name]) &
        ActiveSupport::SecurityUtils.secure_compare(password, basic_auth[:password])
    end
  end
end
