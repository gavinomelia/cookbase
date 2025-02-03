class PagesController < ApplicationController
  before_action :redirect_if_logged_in
  private
  def redirect_if_logged_in
    redirect_to recipes_path if logged_in? # Assuming `logged_in?` is a helper to check user session
  end
end
