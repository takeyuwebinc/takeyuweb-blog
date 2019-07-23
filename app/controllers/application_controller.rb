class ApplicationController < ActionController::Base
  helper_method :authenticated?

  private

  def authenticated?
    return @authenticated if defined?(@authenticate)

    @authenticate =
      authenticate_with_http_basic do |name, password|
        basic_auth = Rails.application.credentials.basic_auth
        ActiveSupport::SecurityUtils.secure_compare(name, basic_auth[:name]) &
          ActiveSupport::SecurityUtils.secure_compare(
            password,
            basic_auth[:password]
          )
      end
  end

  def authenticate
    authenticated? || request_http_basic_authentication
  end
end
