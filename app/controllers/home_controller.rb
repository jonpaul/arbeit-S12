class HomeController < ApplicationController
  def home
    if logged_in?
      # get my projects
      @projects = current_user.projects.all
      project_ids = @projects.map{|p| p.id}
      
      # get my incomplete tasks
      @incomplete_tasks = Task.by_priority.incomplete.map{|task| task if project_ids.include?(task.project_id)}
      
      # get my completed tasks
      @completed_tasks = Task.by_name.completed.map {|task| task if project_ids.include?(task.project_id) }
    end
  end

  def about
  end

  def privacy
  end

  def contact
  end

end