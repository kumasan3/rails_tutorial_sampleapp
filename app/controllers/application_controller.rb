class ApplicationController < ActionController::Base
  # before_action :puts_url
  include SessionsHelper

  private 
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # def puts_url
    #   puts "nononononononnon"
    #   puts request.referrer || "no no square"
    #   puts "nononononononnon"
    # end


end
