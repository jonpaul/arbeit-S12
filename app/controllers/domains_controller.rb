class DomainsController < ApplicationController
  
  before_filter :check_login

  def index
    @domains = Domain.paginate(:page => params[:page]).per_page(10)
  end

  def show
    @domain = Domain.find(params[:id])
  end

  def new
    @domain = Domain.new
  end

  def edit
    @domain = Domain.find(params[:id])
  end

  def create
    @domain = Domain.new(params[:domain])
    if @domain.save
      # if saved to database
      flash[:notice] = "#{@domain.name} has been created."
      redirect_to @domain # go to show domain page
    else
      # return to the 'new' form
      render :action => 'new'
    end
  end

  def update
    @domain = Domain.find(params[:id])
    if @domain.update_attributes(params[:domain])
      flash[:notice] = "#{@domain.name} is updated."
      redirect_to @domain
    else
      render :action => 'edit'
    end
  end

  def destroy
    @domain = Domain.find(params[:id])
    @domain.destroy
    flash[:notice] = "Successfully removed #{@domain.name} from Arbeit."
    redirect_to domains_url
  end
end
