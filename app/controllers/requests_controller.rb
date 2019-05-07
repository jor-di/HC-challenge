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
    @request = Request.find(params[:id])
    if @request.email_confirmed_date.nil?
      current_date = Time.now
      set_email_confirmed_date(@request, current_date)
      set_request_expiring_date(@request, current_date + 3.months)
    end
    redirect_to root_path
  end

  private

  def request_params
    params.require('request').permit(:name, :phone_number, :email, :biography)
  end

  def set_email_confirmed_date(request, date)
    request.email_confirmed_date = date
    request.save
  end

  def set_request_expiring_date(request, date)
    request.request_expiring_date = date
    request.save
  end
end
