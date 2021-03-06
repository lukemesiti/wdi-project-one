class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :check_user

  # GET /tasks
  # GET /tasks.json
  def index
    category = params[:category]
    @current = :all
    @tasks = @current_user.tasks
    @showing_all_tasks = false

    if category.present? && Task::CATEGORIES.include?(category)
      @current = category.to_sym
      @tasks = @tasks.send(category)
      elsif params[:complete].present?
        @current = :complete
        @tasks = @tasks.where(complete: params[:complete])
        @showing_all_tasks = true
      elsif params[:previous].present?
        @current = :previous
        daily = @tasks.previous_daily
        weekly = @tasks.previous_weekly
        yearly = @tasks.previous_yearly
        @tasks = daily + weekly + yearly
        @showing_all_tasks = true
      else
        daily = @tasks.daily
        weekly = @tasks.weekly 
        yearly = @tasks.yearly 
        @tasks = daily + weekly + yearly
        @tasks.sort_by { |t| t.category }
      end
  end



  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
    @current = params[:category].to_sym
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)
    @task.user_id = @current_user.id

    daily_task_count = @current_user.tasks.daily.count
    weekly_task_count = @current_user.tasks.weekly.count
    yearly_task_count = @current_user.tasks.yearly.count

    if @task.category == "daily" && daily_task_count >= 3
      redirect_to user_tasks_path, :alert => 'daily limit reached '
    elsif @task.category == "weekly" && weekly_task_count >= 3
      redirect_to user_tasks_path, :alert => 'weekly limit reached '
    elsif @task.category == "yearly" && yearly_task_count >= 3
      redirect_to user_tasks_path, :alert => 'yearly limit reached '
    else
      respond_to do |format|
        if @task.valid?
          @task.save
          format.html { redirect_to @task, notice: 'Task was successfully created.' }
          format.json { render action: 'show', status: :created, location: @task }
        else
          format.html { render action: 'new' }
          format.json { render json: @task.errors, status: :unprocessable_entity }
        end
      end
    end

  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to user_tasks_url(@task.user) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
      @notes = @task.notes
    end

    def check_user
      if params[:user_id].present?
        if params[:user_id].to_i != @current_user.id.to_i
          redirect_to user_tasks_path(@current_user.id) 
        end
      end
    end

    # Never trust parameters from the internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:name, :category, :description, :complete)
    end
end
