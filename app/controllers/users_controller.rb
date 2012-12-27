class UsersController < ApplicationController
  before_filter :load_and_authorize_user, :only => [:show, :edit, :update]
  before_filter :admin_only, :only => [:index, :notify_subscribers]

  # GET /unsubscribe/:code
  def unsubscribe

    code = params[:code]
    user = User.find_by_unsubscribe_token(code)
    user.subscribe = false
    user.save!

    render text: "you have been successfully unsubscribed from RailsSchool notifications. Thank you for all the good you have, cheers and astalavista."
  end

  def notify_subscribers
    if current_user.email.match(/.*@railsschool.org$/)
      lesson = Lesson.find(params[:id])
      users = User.where(:subscribe => true).to_a
      users.each do |u|
        NotificationMailer.delay.lesson_notification(lesson.id, u.id, current_user.id)
      end
    end
    head :status => 201
  end

  # GET /users
  def index
    @users = User.all
  end

  # GET /users/1
  def show
  end

  # GET /users/1/edit
  def edit
  end

  # PUT /users/1
  def update

    if @user.update_attributes(params[:user])
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: "edit"
    end
  end

private
  def load_and_authorize_user
    @user = User.find(params[:id])
    redirect_to root_path unless (admin? || @user == current_user)
  end
end
