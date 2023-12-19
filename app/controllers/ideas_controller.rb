class IdeasController < ApplicationController
  def index
    @problem = Idea.first
    @ideas = Idea.where(parent_id: 1).all
  end

  def solution
    @ideas = Idea.where(parent_id: 1).all
  end

  def first_create
    @idea = Idea.new(idea_params)
    if @idea.save
      render :index
    end
  end

  def edit
    @idea = Idea.find(params[:id])
  end


  def create
    idea_params = params.require(:idea).permit(name: [])
    idea_params[:name].each do |name|
      Idea.create(name: name,parent_id: 1)
    end
    redirect_to solution_ideas_path, notice: '登録が完了しました'
  end



  def update
    @idea = Idea.find(params[:id])
    if @idea.update(idea_params)
      redirect_to ideas_path, notice: 'タスクが更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @idea = Idea.find(params[:id])
    @idea.destroy
    redirect_to ideas_path, notice: 'タスクが削除されました。'
  end


  private

  def idea_params
    params.require(:idea).permit(:name, :parent_id)
  end


end
