class ProjectsController < ApplicationController

  before_filter :check_login
  authorize_resource

  def index
    @current_projects = Project.current.alphabetical.paginate(:page => params[:page]).per_page(7)
    @past_projects = Project.past.alphabetical
  end

  def show
    @project = Project.find(params[:id])
    authorize! :read, @project
    @project_tasks = @project.tasks.chronological.by_priority.paginate(:page => params[:page]).per_page(10)
    @project_assignments = @project.assignments.by_user.paginate(:page => params[:page]).per_page(8)
  end

  def new
    @project = Project.new
  end

  def edit
    @project = Project.find(params[:id])
    # if shortcut access via projects#index
    if !params[:status].nil? && params[:status] == 'end'
      @project.update_attribute(:end_date, Time.now.to_date)
      flash[:notice] = "#{@project.name} was ended as of today."
      redirect_to projects_path
    end
    # else prepare the dates for display
    @project.start_date = humanize_date @project.start_date
    @project.end_date = humanize_date @project.end_date
    
  end

  def create
    @project = Project.new(params[:project])
    @project.manager_id = current_user.id 
    @project.start_date = convert_to_date(params[:project][:start_date]) # unless params[:project][:start_date].blank?
    @project.end_date = convert_to_date(params[:project][:end_date]) # unless params[:project][:end_date].blank?
    
    if @project.save
      # if saved to database
      flash[:notice] = "#{@project.name} has been created."
      redirect_to @project # go to show project page
    else
      # return to the 'new' form
      render :action => 'new'
    end
  end

  def update    
    @project = Project.find(params[:id])
    params[:project][:start_date] = convert_to_date(params[:project][:start_date])
    params[:project][:end_date] = convert_to_date(params[:project][:end_date])
    
    if @project.update_attributes(params[:project])
      flash[:notice] = "#{@project.name} has been updated."
      redirect_to @project
    else
      render :action => 'edit'
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    flash[:notice] = "Successfully removed #{@project.name} from Arbeit."
    redirect_to projects_url
  end
end
