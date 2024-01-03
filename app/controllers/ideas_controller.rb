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
    @problem = Idea.first
    @root = Idea.find(params[:id])
    @ideas = @root.children
    @tree_view = Idea.tree_view(:name)
  end

  def set_easy_points
    @all_solutions = Idea.leaves
    easy_points_params = params.require(:idea).permit(:easy_point)

    @all_solutions.each do |solution|
      easy_point = params["idea"][:"#{solution.id}_easy_point"].first
      idea = Idea.find(solution.id)
      idea.update(easy_point: easy_point)
    end

    redirect_to evaluate_ideas_path, notice: '①の評価が完了しました'
  end

  def set_effect_points
    @all_solutions = Idea.leaves
    effect_points_params = params.require(:idea).permit(:effect_point)

    @all_solutions.each do |solution|
      effect_point = params["idea"][:"#{solution.id}_effect_point"].first
      idea = Idea.find(solution.id)
      idea.update(effect_point: effect_point)
    end

    redirect_to evaluate_ideas_path, notice: '②が完了しました'
  end




  def evaluate
    @problem = Idea.first
    @all_solutions = Idea.leaves
  end


  def edit
    @idea = Idea.find(params[:id])
  end


  def create
    idea_params = params.require(:idea).permit(:parent_id, name: [])
    @parent_id = idea_params[:parent_id]
    idea_params[:name].each do |name|
      parent = Idea.find_by(id: @parent_id)
      parent.children.create(name: name)
    end
    redirect_to solution_idea_path(id: @parent_id), notice: '登録が完了しました'
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
      :easy_point,
      :effect_point,
      :parent_id
    )
  end



end
