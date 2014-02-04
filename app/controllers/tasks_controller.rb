class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :check_user

  # GET /tasks
  # GET /tasks.json
  def index
      if params[:category].present?
        @tasks = @current_user.tasks.where("category = ?", params[:category])
      elsif params[:complete].present?
        @tasks = @current_user.tasks.where("complete = ?", params[:complete])
      else
        @tasks = @current_user.tasks.all
      end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
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
      redirect_to user_tasks_path, :notice => 'daily limit reached '
    elsif @task.category == "weekly" && weekly_tasks >= 3
      redirect_to user_tasks_path, :notice => 'weekly limit reached '
    elsif @task.category == "yearly" && yearly_tasks >= 3
      redirect_to user_tasks_path, :notice => 'yearly limit reached '
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
          redirect_to user_tasks_path(@current_user.id), :notice => 'dont try to change user!'
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:name, :category, :description, :complete, :user_id)
    end
end
