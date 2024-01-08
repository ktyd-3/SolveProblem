class IdeasController < ApplicationController

  def index
    @problem = Idea.first
    @ideas = Idea.where(parent_id: @problem.id).all
  end


  def first_create
    name = params.dig(:idea, :name)
    root = Idea.create(name: name)
    redirect_to root_path
  end


  def create
    idea_params = params.require(:idea).permit(:parent_id ,name: [], parent_id: [])
    this_idea_parent_id = params.dig(:idea, :parent_id)
    parent = Idea.find(this_idea_parent_id)
    idea_params[:name].each do |name|
      parent = Idea.find(this_idea_parent_id)
      parent.children.create(name: name)
    end
    redirect_to "/ideas/#{this_idea_parent_id}/solution", notice: '登録が完了しました'
  end


  def solution
    @root_idea = Idea.find_by(id: params[:id])
    @problem = Idea.first
    @ideas = @root_idea.children.includes(:children) if @root_idea.present?
  end


  def evaluate
    @problem = Idea.first
    @all_solutions = Idea.leaves.includes(:children)
    @solution_evaluations = []

    @all_solutions.each do |solution|
      if solution.effect_point.present? && solution.easy_point.present?
        @solution_evaluations << (solution.effect_point * solution.easy_point)
      end
    end
  end

  def set_easy_points
    @all_solutions = Idea.leaves.includes(:children)
    easy_points_params = params.require(:idea).permit!

    @all_solutions.each do |solution|
      easy_point = params["idea"][:"#{solution.id}_easy_point"].first
      idea = Idea.find(solution.id)
      idea.update(easy_point: easy_point)
    end

    redirect_to evaluate_ideas_path, notice: '①の評価が完了しました'
  end

  def set_effect_points
    @all_solutions = Idea.leaves.includes(:children)
    effect_points_params = params.require(:idea).permit!

    @all_solutions.each do |solution|
      effect_point = params["idea"][:"#{solution.id}_effect_point"].first
      idea = Idea.find(solution.id)
      idea.update(effect_point: effect_point)
    end

    redirect_to evaluate_ideas_path, notice: '②が完了しました'
  end


  def edit
    @idea = Idea.find_by(id: params[:id])
  end

  def update
    @idea = Idea.find_by(id: params[:id])
    if @idea.update(idea_params)
      redirect_to solution_idea_path(@idea.parent_id), notice: 'アイデアが更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @idea = Idea.find_by(id: params[:id])
    @idea_family = @idea.self_and_descendants
    @idea_family.destroy
    redirect_to solution_idea_path(@idea.parent_id), notice: 'タスクが削除されました。'
  end


  private

  def idea_params
    params.require(:idea).permit(
      :name,
      :parent_id,
      :effect_point,
      :easy_point,
      name: [],
      parent_id: []
      )
  end



end
