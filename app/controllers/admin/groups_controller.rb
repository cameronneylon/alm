class Admin::GroupsController < Admin::ApplicationController
  
  # GET /groups
  def index
    @groups = Group.order("name")
    respond_with do |format|  
      format.js { render :index }
    end
  end

  # GET /groups/:id/edit
  def edit
    @groups = Group.order("name")
    @group = Group.find(params[:id])
    respond_with(@group) do |format|  
      format.js { render :index }
    end
  end

  # PUT /groups/:id
  def update
    @groups = Group.order("name")
    @group = Group.find(params[:id])
    @group.update_attributes(params[:group])
    respond_with(@group) do |format|  
      format.js { render :index }
    end
  end

  # DELETE /groups/:id
  def destroy
    @groups = Group.order("name")
    @group = Group.find(params[:id])
    @group.destroy
    respond_with(@group) do |format|  
      format.js { render :index }
    end
  end

  # GET /groups/new
  def new
    @group = Group.new
    respond_with(@group) do |format|  
      format.js { render :index }
    end
  end

  # POST /groups
  def create
    @groups = Group.order("name")
    @group = Group.new(params[:group])
    @group.save
    respond_with(@group) do |format|  
      format.js { render :index }
    end
  end
  
end