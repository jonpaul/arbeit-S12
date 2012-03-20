namespace :db do
  desc "Erase and fill database"
  # creating a rake task within db namespace called 'populate'
  # executing 'rake db:populate' will cause this script to run
  task :populate => :environment do
    # Invoke rake db:migrate just in case...
    Rake::Task['db:migrate'].invoke
    
    # Need the faker gem to make this work
    # Docs at: http://faker.rubyforge.org/rdoc/
    require 'faker'
    
    # Step 1: clear any old data in the db
    [Assignment, Task, Domain, Project, User].each(&:delete_all)
    
    
    # Step 2: add Prof. H as a default member and manager for every default project
    u = User.new
    u.first_name = "Professor"
    u.last_name = "Heimann"
    u.email = "profh@cmu.edu"
    u.password = "secret"
    u.password_confirmation = "secret"
    u.active = true
    u.role = "admin"
    u.save!
    
    
    # Step 3: add some domains to work with (small set for now...)
    domains = %w[Software Personal Academic]
    domains.sort.each do |domain|
      d = Domain.new
      d.name = domain
      d.save!
    end
    
    
    # Step 4: add some projects to work with (just four for now)
    projects = %w[ChoreTracker Proverbs Arbeit BookManager]
    domain_id = Domain.find_by_name('Software').id  # all projects are software projects
    manager_id = User.first.id                      # Prof. H manages all the default projects
    
    projects.sort.each do |project|
      p = Project.new
      p.name = project
      p.description = "A most glorious project that will bring fame and honor to all those who are associated with it.  This project will also be a rich blessing to all who use it properly."
      started = rand(4) + 2
      ends = rand(3) + 3
      p.start_date = started.months.ago.to_date
      p.end_date = ends.months.from_now.to_date
      p.domain_id = domain_id
      p.manager_id = manager_id
      p.save!
    end
    
    # Step 6: assign Prof. H to each project
    project_ids = Project.all.map{|p| p.id}
    project_ids.each do |project|
      a = Assignment.new
      a.user_id = User.first.id
      a.project_id = project
      a.active = true
      a.save!
    end

        
    # Step 6: add 16 more users to the system and assign to projects
    16.times do 
      user = User.new
      user.first_name = Faker::Name.first_name
      user.last_name = Faker::Name.last_name
      user.email = "#{user.first_name.downcase}.#{user.last_name.downcase}@example.com"
      user.password = "secret"
      user.password_confirmation = "secret"
      user.active = true
      user.role = "member"
      user.save!
      
      # Step 5A: assign 1 project for each user for now
        assignment = Assignment.new
        assignment.user_id = user.id
        assignment.project_id = project_ids.sample
        assignment.active = true
        assignment.save!
    end
    
    # Step 6: add some tasks and assign them to projects
    tasks = %w[Data\ modelling Validate\ models Add\ relationships Modify\ controllers Create\ stylesheets Add\ authorization Requirements\ analysis Wireframing Unit\ testing Security\ checking User\ testing Integration\ testing]
    16.times do 
      task = Task.new
      task.name = tasks.sample
      task.project_id = project_ids.sample
      task.priority = (1..3).to_a.sample    # no task is a 4 (the 'who cares?' priority)
      due = (-42..42).to_a.sample
      task.due_string = due.days.ago.to_s  # a 'negative' days ago is in the future
      task.save!
      # now edit the task to add creators and completers
      assigned_users = Assignment.for_project(task.project_id).map{|u| u.id}
      task.created_by = assigned_users.sample
      if task.due_on < Time.now
        task.completed = true
        task.completed_by = assigned_users.sample
      else
        task.completed = false
      end
      task.save!
    end  
  end
end
