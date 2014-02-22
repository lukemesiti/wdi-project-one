class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :check_user

  # GET /tasks
  # GET /tasks.json
  def index
    @current = :all
    @tasks = @current_user.tasks
      if params[:category] == 'daily'
        @current = :daily
        @tasks = get_tasks_by_time_period(@current_user, params[:category], Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
      elsif params[:category] == 'weekly'
        @current = :weekly
        @tasks = get_tasks_by_time_period(@current_user, params[:category], Time.zone.now.beginning_of_week, Time.zone.now.end_of_week)
      elsif params[:category] == 'yearly'
        @current = :yearly
        @tasks = get_tasks_by_time_period(@current_user, params[:category], Time.zone.now.beginning_of_year, Time.zone.now.end_of_year)
      elsif params[:complete].present?
        @current = :complete
        @tasks = @tasks.where("complete = ?", params[:complete])
      elsif params[:previous].present?
        @current = :previous
        daily = get_tasks_before_time_period(@current_user, 'daily', Time.zone.now.beginning_of_day)
        weekly = get_tasks_before_time_period(@current_user, 'weekly', Time.zone.now.beginning_of_week)
        yearly = get_tasks_before_time_period(@current_user, 'yearly', Time.zone.now.beginning_of_year)
        @tasks = daily + weekly + yearly
      else
        daily = get_tasks_by_time_period(@current_user, 'daily', Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
        weekly = get_tasks_by_time_period(@current_user, 'weekly', Time.zone.now.beginning_of_week, Time.zone.now.end_of_week) 
        yearly = get_tasks_by_time_period(@current_user, 'yearly', Time.zone.now.beginning_of_year, Time.zone.now.end_of_year) 
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
    # @current = :alltasks
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)

    daily_task_count = get_tasks_by_time_period(@current_user,'daily',Time.zone.now.beginning_of_day, Time.zone.now.end_of_day).count
    weekly_task_count = get_tasks_by_time_period(@current_user,'weekly',Time.zone.now.beginning_of_week, Time.zone.now.end_of_week).count
    yearly_task_count = get_tasks_by_time_period(@current_user,'yearly',Time.zone.now.beginning_of_year, Time.zone.now.end_of_year).count

    if @task.category == "daily" && daily_task_count >= 3
      redirect_to user_tasks_path, :alert => 'daily limit reached '
    elsif @task.category == "weekly" && weekly_task_count >= 3
      redirect_to user_tasks_path, :alert => 'weekly limit reached '
    elsif @task.category == "yearly" && yearly_task_count >= 3
      redirect_to user_tasks_path, :alert => 'yearly limit reached '
    else
      respond_to do |format|
        if @task.save
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
          redirect_to user_tasks_path(@current_user.id) # , :notice => "Don't try to change the user!"
        end
      end
    end

    def get_tasks_by_time_period(user, category, date_from, date_to)
       user.tasks.where("category = ? AND created_at >= ? AND created_at <= ?", category, date_from, date_to)
    end

    def get_tasks_before_time_period(user, category, date_to)
      user.tasks.where("category = ? AND created_at <= ?", category, date_to)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:name, :category, :description, :complete, :user_id)
    end
end
