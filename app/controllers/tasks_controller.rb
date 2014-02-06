class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :check_user

  # GET /tasks
  # GET /tasks.json
  def index
    @current = :all
      if params[:category] == 'daily'
        @current = :daily
        @tasks = @current_user.tasks.where("category = ? AND created_at >= ? AND created_at <= ?", 'daily', Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
      elsif params[:category] == 'weekly'
        @current = :weekly
        @tasks = @current_user.tasks.where("category = ? AND created_at >= ? AND created_at <= ?", 'weekly', Time.zone.now.beginning_of_week, Time.zone.now.end_of_week)
      elsif params[:category] == 'yearly'
        @current = :yearly
        @tasks = @current_user.tasks.where("category = ? AND created_at >= ? AND created_at <= ?", 'yearly', Time.zone.now.beginning_of_year, Time.zone.now.end_of_year)
      elsif params[:complete].present?
        @current = :complete
        @tasks = @current_user.tasks.where("complete = ?", params[:complete])
      elsif params[:previous].present?
        @current = :previous
        daily = @current_user.tasks.where("category = ? AND created_at <= ?", 'daily', Time.zone.now.beginning_of_day) # previous daily
        weekly = @current_user.tasks.where("category = ? AND created_at <= ?", 'weekly', Time.zone.now.beginning_of_week) # previous week
        yearly = @current_user.tasks.where("category = ? AND created_at <= ?", 'yearly', Time.zone.now.beginning_of_year) # previous week
        @tasks = daily + weekly + yearly
      else
        daily = @current_user.tasks.where("category = ? AND created_at >= ? AND created_at <= ?", 'daily', Time.zone.now.beginning_of_day, Time.zone.now.end_of_day)
        weekly = @current_user.tasks.where("category = ? AND created_at >= ? AND created_at <= ?", 'weekly', Time.zone.now.beginning_of_week, Time.zone.now.end_of_week) 
        yearly = @current_user.tasks.where("category = ? AND created_at >= ? AND created_at <= ?", 'yearly', Time.zone.now.beginning_of_year, Time.zone.now.end_of_year) 
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
    # @current = :alltasks
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)

  daily_tasks = @current_user.tasks.where("category = ? AND created_at >= ? AND created_at <= ?", 'daily', Time.zone.now.beginning_of_day, Time.zone.now.end_of_day).count
  weekly_tasks = @current_user.tasks.where("category = ? AND created_at >= ? AND created_at <= ?", 'weekly', Time.zone.now.beginning_of_week, Time.zone.now.end_of_week).count
  yearly_tasks = @current_user.tasks.where("category = ? AND created_at >= ? AND created_at <= ?", 'yearly', Time.zone.now.beginning_of_year, Time.zone.now.end_of_year).count

    if @task.category == "daily" && daily_tasks >= 3
      redirect_to user_tasks_path, :alert => 'daily limit reached '
    elsif @task.category == "weekly" && weekly_tasks >= 3
      redirect_to user_tasks_path, :alert => 'weekly limit reached '
    elsif @task.category == "yearly" && yearly_tasks >= 3
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:name, :category, :description, :complete, :user_id)
    end
end
