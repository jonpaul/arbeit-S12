class UsersController < ApplicationController

  def index
    @users = User.alphabetical.paginate(:page => params[:page]).per_page(7)
  end

  def show
    @user = User.find(params[:id])
    @user_assignments = @user.assignments.active.by_project
    @created_tasks = Task.for_creator(@user.id).by_name
    @completed_tasks = Task.for_completer(@user.id).by_name
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_url, notice: "Thank you for signing up!"
    else
      flash[:error] = "This user could not be created."
      render "new"
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "#{@user.proper_name} is updated."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "Successfully removed #{@user.proper_name} from Arbeit."
    redirect_to users_url
  end
end
