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
      current_time = Time.now
      request.confirm_email!(current_time)
      request.update_expiring_date!(current_time)
    end
    redirect_to root_path
  end

  def renew_expiring_date
    request = Request.find(params[:id])
    today = Date.today
    expiring_date = request.request_expiring_date
    if expiring_date < today
      expiring_date > 7.days.ago ? request.update_expiring_date!(today) : request.expired!
    end
    redirect_to root_path
  end

  private

  def request_params
    params.require('request').permit(:name, :phone_number, :email, :biography)
  end
end
