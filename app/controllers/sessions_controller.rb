class SessionsController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
  prepend_before_filter :allow_params_authentication!, :only => :create
  prepend_before_filter { request.env["devise.skip_timeout"] = true }

  # GET /resource/sign_in
  def new
  	destroy_guest
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
    render :layout=>false
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  def destroy
   super
  end

  protected

  def sign_in_params
    devise_parameter_sanitizer.sanitize(:sign_in)
  end

  def serialize_options(resource)
    methods = resource_class.authentication_keys.dup
    methods = methods.keys if methods.is_a?(Hash)
    methods << :password if resource.respond_to?(:password)
    { :methods => methods, :only => [:password] }
  end

  def auth_options
    { :scope => resource_name, :recall => "#{controller_path}#new" }
  end

  def destroy_guest
  	if session[:guest_user_id]
			User.find(session[:guest_user_id]).destroy
			session[:guest_user_id] = nil
		end
  end
end