class SessionsController < ApplicationController
  
  def new
  end

  def create
    user = login(params[:email], params[:password], params[:remember])
    if user
      redirect_to root_path, notice: 'Logged in successfully.'
    else
      flash.now[:alert] = 'Invalid email or password.'
      render :new
    end
  end

   def destroy
    logout
    redirect_to root_path, notice: 'Logged out successfully.'
  end
end

