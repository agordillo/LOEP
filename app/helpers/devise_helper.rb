module DeviseHelper

  #Overwrite default method
  def devise_error_messages!
    resource.errors.full_messages
  end
end