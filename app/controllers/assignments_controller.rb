class AssignmentsController < ApplicationController
  
  before_filter :check_login
  authorize_resource

  def index
    @active_assignments = Assignment.active.by_project.by_user.paginate(:page => params[:page]).per_page(10)
    @inactive_assignments = Assignment.inactive.by_project.by_user.paginate(:page => params[:page]).per_page(10)
  end

  def show
    @assignment = Assignment.find(params[:id])
  end

  def new
    @assignment = Assignment.new
    @assignment.project_id = params[:id] unless params[:id].nil?
  end

  def edit
    @assignment = Assignment.find(params[:id])
    
    # Handle shortcut deactivations
    unless params[:status].nil?
      if params[:status].match(/deactivate/) # == 'deactivate_prj' || params[:status] == 'deactivate_asgn'
        @assignment.update_attribute(:active, false)
        flash[:notice] = "#{@assignment.user.proper_name} was made inactive."
      elsif params[:status].match(/activate/) # == 'activate_prj' || params[:status] == 'activate_asgn'
        @assignment.update_attribute(:active, true)
        flash[:notice] = "#{@assignment.user.proper_name} was made active."
      end
      redirect_to project_path(@assignment.project) if params[:status].match(/_prj/)
      redirect_to assignments_path if params[:status].match(/_asgn/)
    end
  end

  def create
    @assignment = Assignment.new(params[:assignment])
    if @assignment.save
      # if saved to database
      flash[:notice] = "#{@assignment.user.proper_name} is assigned to #{@assignment.project.name}."
      redirect_to @assignment # go to show assignment page
    else
      # return to the 'new' form
      render :action => 'new'
    end
  end

  def update
    @assignment = Assignment.find(params[:id])
    if @assignment.update_attributes(params[:assignment])
      flash[:notice] = "#{@assignment.user.proper_name}'s assignment to #{@assignment.project.name} is updated."
      redirect_to @assignment
    else
      render :action => 'edit'
    end
  end

  def destroy
    @assignment = Assignment.find(params[:id])
    @assignment.destroy
    flash[:notice] = "Successfully removed #{@assignment.user.proper_name} from #{@assignment.project.name}."
    redirect_to assignments_url
  end
end
