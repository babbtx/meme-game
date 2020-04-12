module CurrentUser
  extend ActiveSupport::Concern
  include JwtSecured

  class UserNotFound < ActiveRecord::RecordNotFound
  end

  included do
    before_action :ensure_current_user
    rescue_from UserNotFound, with: :render_jwt_unauthorized
  end

  private

  # locates the user identified by the 'sub' attribute of the authz_jwt
  def current_user
    @current_user ||= begin
      authenticate_request!
      User.find_by(token_subject: @authz_jwt[:sub])
    end
  end

  # locates the user identified by the 'sub' attribute of the authz_jwt
  # if that user doesn't exist, it creates the user, and if that fails,
  # raises UserNotFound (which by default renders unauthorized)
  def current_user!
    @current_user = current_user || User.create!(token_subject: @authz_jwt[:sub])
  rescue ActiveRecord::ActiveRecordError => ex
    raise UserNotFound.new(ex.message)
  end

  def ensure_current_user
    !! current_user!
  end
end