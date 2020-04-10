module SignIn
  extend ActiveSupport::Concern

  attr_reader :current_user

  def sign_in(user)
    @current_user = user
    @authz_header = {'Authorization': "Bearer #{JWT.encode({sub: user.uuid}, 'secret')}"}
  end

  def sign_out
    @current_user = nil
    @authz_header = nil
  end

  included do
    %w(get post patch put head delete).each do |method|
      # if signed in, add the authz header by default
      define_method(method) do |*args, headers: nil, **keywords|
        if @authz_header
          headers = headers ? headers.merge(@authz_header) : @authz_header
        end
        super(*args, headers: headers, **keywords)
      end
    end
  end
end

ActionDispatch::IntegrationTest.send(:include, SignIn)