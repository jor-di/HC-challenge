class RequestsController < ApplicationController
  def new
    @request = Request.new
  end

  def create
    @request = Request.new(request_params)
    if @request.save
      flash[:success] = 'Welcome on board ! Please, check your emails to complete your subscription.'
      redirect_to root_path
    else
      flash.now[:success] = 'Sorry, something went wrong with your data. Please check your info and try again!'
      render 'new'
    end
  end

  def confirm_email
    request = Request.find(params[:id])
    if request.email_confirmed_date.nil?
      request.confirm_email!
      request.update_expiring_date!
      flash[:success] = "Thank you, your subscription is confirmed.
                         You are on the #{request.waiting_list_position.ordinalize} position on the waiting list.
                         We will come back to you soon!"
    end
    redirect_to root_path
  end

  def renew_expiring_date
    request = Request.find(params[:id])
    today = Date.today
    expiring_date = request.request_expiring_date
    if expiring_date <= today && request.expired == false # check if expiring date is passed (avoid double validation + kind of restriction over hacking) and not expired. Should implement a token system for better authentication.
      request.update_expiring_date!
    end
    redirect_to root_path
  end

  private

  def request_params
    params.require('request').permit(:name, :phone_number, :email, :biography)
  end
end
