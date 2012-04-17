class TasksController < ApplicationController
  
  before_filter :check_login
  authorize_resource

  def index
    @pending_tasks = Task.incomplete.chronological.paginate(:page => params[:page]).per_page(7)
    @completed_tasks = Task.completed.by_completion_date.last(20)
  end

  def show
    @task = Task.find(params[:id])
    authorize! :show, @task
  end

  def new
    @task = Task.new
    authorize! :new, @task
    @task.project_id = params[:project_id] unless params[:project_id].nil?
  end

  def edit
    @task = Task.find(params[:id])
    authorize! :edit, @task
    @task.due_on = humanize_date(@task.due_on) if params[:status].nil?
    # in case this is a quick complete...
    if !params[:status].nil? && params[:status] == 'completed'
      @task.completed = true
      @task.completed_by = current_user.id
      @task.save!
      flash[:notice] = "#{@task.name} has been marked complete."
      if params[:from] == 'project'
        redirect_to project_path(@task.project)
      else
        redirect_to tasks_path
      end
    end
  end

  def create
    @task = Task.new(params[:task])
    authorize! :create, @task
    @task.created_by = current_user.id
    @task.due_on = convert_to_datetime(params[:task][:due_on])
    if @task.save
      # if saved to database
      flash[:notice] = "#{@task.name} has been created."
      redirect_to @task # go to show task page
    else
      # return to the 'new' form
      render :action => 'new'
    end
  end

  def update
    @task = Task.find(params[:id])
    authorize! :update, @task
    params[:task].each { |attribute,value| @task[attribute] = value }
    @task.due_on = convert_to_datetime(params[:task][:due_on])
    if params[:task][:completed] == "1"
      @task.completed_by = current_user.id
    else
      @task.completed_by = nil
    end
    if @task.save!
      flash[:notice] = "#{@task.name} is updated."
      redirect_to @task
    else
      render :action => 'edit'
    end
  end

  def destroy
    @task = Task.find(params[:id])
    authorize! :destroy, @task
    @task.destroy
    flash[:notice] = "Successfully removed #{@task.name} from Arbeit."
    redirect_to tasks_url
  end
  
  # ===================================
  # Two new methods to handle changing completed field
  def complete
    @task = Task.find(params[:id])
    # set completed and completed_by fields
    @task.completed = true
    @task.completed_by = current_user.id

    if @task.save!
      flash[:notice] = 'Task was marked as completed.'
      if params[:status] == "task_details"
        redirect_to task_path(@task)
      else
        redirect_to home_path
      end
    else
      render :action => "edit"
    end
  end

  def incomplete
    @task = Task.find(params[:id])
    @task.completed = false
    @task.completed_by = nil

    if @task.save!
      flash[:notice] = 'Task was changed back to incomplete.'
      redirect_to task_path(@task)
    else
      render :action => "edit"
    end
  end
end
