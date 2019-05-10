class RequestsController < ApplicationController
  def new
    @request = Request.new
  end

  def create
    @request = Request.new(request_params)
    if @request.save
      create_flash(:success)
      redirect_to root_path
    else
      create_flash(:failure)
      render 'new'
    end
  end

  def confirm_email
    request = Request.find(params[:id])
    if request.email_confirmed_date.nil?
      request.confirm_email!
      request.update_expiring_date!
      confirm_email_flash(:success, request)
    else
      confirm_email_flash(:failure, request)
    end
    redirect_to root_path
  end

  def renew_expiring_date
    request = Request.find(params[:id])
    today = Date.today
    expiring_date = request.request_expiring_date
    if expiring_date <= today && request.expired == false # check if expiring date is passed (avoid double validation + kind of restriction over hacking) and not expired. Should implement a token system for better authentication.
      request.update_expiring_date!
      renew_expiring_date_flash(:success, request)
    else
      renew_expiring_date_flash(:failure)
    end
    redirect_to root_path
  end

  private

  def create_flash(type)
    case type
    when :success
      flash[:success] = 'Welcome on board ! Please, check your emails to complete your subscription.'
    when :failure
      flash.now[:danger] = 'Sorry, something went wrong with your data. Please check your info and try again!'
    end
  end

  def confirm_email_flash(type, request)
    case type
    when :success
      flash[:success] = "Thank you, your subscription is confirmed. #{request.waiting_list_position_to_text} We will come back to you soon!"
    when :failure
      flash[:danger] = "You already confirmed your email. #{request.waiting_list_position_to_text if Request.confirmed.include?(request)}"
    end
  end

  def renew_expiring_date_flash(type, request = nil)
    case type
    when :success
      flash[:success] = "Thank you for the update. #{request.waiting_list_position_to_text} We will come back to you soon!"
    when :failure
      flash[:danger] = 'Sorry, this link is not active anymore.'
    end
  end

  def request_params
    params.require('request').permit(:name, :phone_number, :email, :biography)
  end
end
