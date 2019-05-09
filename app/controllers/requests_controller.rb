class RequestsController < ApplicationController
  def new
    @request = Request.new
  end

  def create
    @request = Request.new(request_params)
    if @request.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  def confirm_email
    request = Request.find(params[:id])
    if request.email_confirmed_date.nil?
      request.confirm_email!
      request.update_expiring_date!
    end
    redirect_to root_path
  end

  def renew_expiring_date
    request = Request.find(params[:id])
    today = Date.today
    expiring_date = request.request_expiring_date
    if expiring_date < today && request.expired == false # check if expiring date is passed (avoid double validation + kind of restriction over hacking) and not expired. Should implement a token system for better authentication.
      request.update_expiring_date!
    end
    redirect_to root_path
  end

  private

  def request_params
    params.require('request').permit(:name, :phone_number, :email, :biography)
  end
end
