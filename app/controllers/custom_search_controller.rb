class CustomSearchController < ApplicationController

  #Custom search
  def index
    unless user_signed_in? and current_user.isAdmin?
      redirect_to home_path
    end
    
    @los = Lo.all
  end


end