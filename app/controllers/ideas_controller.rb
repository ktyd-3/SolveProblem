class IdeasController < ApplicationController

  def index
    @problem = Idea.first
    @ideas = Idea.where(parent_id: 1).all
  end


  def first_create
    name = params.dig(:idea, :name)
    root = Idea.create(name: name)
    redirect_to ideas_path
  end

  def solution
    root = Idea.first
    @ideas = root.children
    @tree_view = Idea.tree_view(:name)
  end



  def edit
    @idea = Idea.find(params[:id])
  end


  def create
    idea_params = params.require(:idea).permit(name: [], parent_id: [])
    this_idea_parent_id = params.dig(:idea, :parent_id)
    idea_params[:name].each do |name|
      parent = Idea.find(this_idea_parent_id)
      parent.children.create(name: name)
    end
    redirect_to solution_path(this_idea_parent_id), notice: '登録が完了しました'
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
    params.require(:idea).permit(
      :name,
      :parent_id,
      name: [],
      parent_id: []
      )
  end



end
