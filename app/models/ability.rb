class Ability
  include CanCan::Ability
  
  def initialize(user)
    # set user to new User if not logged in
    user ||= User.new # i.e., a guest user
    
    # set authorizations for different user roles
    if user.role? :admin
      # they get to do it all
      can :manage, :all
      
    elsif user.role? :member
      # can see a list of all users
      can :index, User
      
      # they can read their own profile
      can :show, User do |u|  
        u.id == user.id
      end
      # they can update their own profile
      can :update, User do |u|  
        u.id == user.id
      end
      
      # they can read their own projects' data
      can :read, Project do |this_project|  
        my_projects = user.projects.map{|p| p.id}
        my_projects.include? this_project.id 
      end
      # they can create new projects for themselves
      can :create, Project
      
      # they can update the project only if they are the manager (creator)
      can :update, Project do |this_project|
        managed_projects = user.projects.map{|p| p.id if p.manager_id == user.id}
        managed_projects.include? this_project.id
      end
            
      # they can read tasks in these projects
      can :read, Task do |this_task|  
        project_tasks = user.projects.map{|p| p.tasks.map{|t| t.id}}.flatten
        project_tasks.include? this_task.id 
      end
      
      # they can update tasks in these projects
      can :update, Task do |this_task|  
        project_tasks = user.projects.map{|p| p.tasks.map{|t| t.id}}.flatten
        project_tasks.include? this_task.id 
      end
      
      # they can create new tasks for these projects
      can :create, Task do |this_task|  
        my_projects = user.projects.map{|p| p.id}
        my_projects.include? this_task.project_id  
      end

    else
      # guests can only read domains covered (plus home pages)
      can :read, Domain
    end
  end
end