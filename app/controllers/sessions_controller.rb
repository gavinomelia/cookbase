class SessionsController < ApplicationController
  
  def new
  end

  def create
    user = login(params[:email], params[:password], params[:remember])
    if user
      redirect_to root_path, notice: 'Logged in successfully.'
    else
      redirect_to login_path, notice: 'Invalid email or password.'
    end
  end

   def destroy
    logout
    redirect_to root_path, notice: 'Logged out successfully.'
  end
end

