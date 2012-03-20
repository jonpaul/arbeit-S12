module TasksHelper
  def get_priority_class(code)
    if code.to_i == 1
      "high_priority"
    elsif code.to_i == 2
      "med_priority"
    else "low_priority"
    end
  end
  
  def get_priority_name(code)
    if code.to_i == 1
      "High"
    elsif code.to_i == 2
      "Med"
    else "Low"
    end
  end
  
  def get_task_status(status)
    return "Yes" if status == true
    "No"
  end
  
  def get_project_options
    current_user.projects.map{|p| ["#{p.name}", p.id] }
  end
  
end