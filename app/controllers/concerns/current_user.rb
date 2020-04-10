module CurrentUser
  extend ActiveSupport::Concern
  include JwtSecured

  class UserNotFound < ActiveRecord::RecordNotFound
  end

  included do
    rescue_from UserNotFound, with: :render_jwt_unauthorized
  end

  private

  # locates the user identified by the 'sub' attribute of the authz_jwt
  # if that user doesn't exist, it creates the user
  # renders
  def current_user!
    @current_user ||= begin
      authenticate_request!
      subject = @authz_jwt[:sub]
      User.find_by(uuid: subject) || User.create!(uuid: subject)
    end
  rescue ActiveRecord::RecordNotSaved => ex
    raise UserNotFound.new(ex.message)
  end
end