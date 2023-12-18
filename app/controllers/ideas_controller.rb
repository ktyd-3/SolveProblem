class IdeasController < ApplicationController
  def index
    @problem = Idea.first
    @ideas = Idea.where(parent_id: 1).all
  end

  def first_create
    @idea = Idea.new(idea_params)
    if @idea.save
      render :index
    end
  end


  def create
    idea_params = params.require(:idea).permit(name: [])
    idea_params[:name].each do |name|
      Idea.create(name: name,parent_id: 1)
    end
    redirect_to solution_tasks_path, notice: '登録が完了しました'
  end



  def update
    @task = Task.find(params[:id])
    if @task.update(task_params)
      redirect_to tasks_path, notice: 'タスクが更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    redirect_to tasks_path, notice: 'タスクが削除されました。'
  end


  private

  def idea_params
    params.require(:idea).permit(:name, :parent_id)
  end


end
