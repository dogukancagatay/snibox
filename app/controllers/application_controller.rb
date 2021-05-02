class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!, unless: -> { ENV['DISABLE_AUTH'] == "true" }
  before_action :set_properties

  def set_properties
    @activate_repository = false
    @body_class = "default"
    @page_title = ""
  end
end
