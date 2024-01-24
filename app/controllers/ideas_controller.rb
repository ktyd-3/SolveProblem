class IdeasController < ApplicationController
  require "ruby-graphviz"
  before_action :search_initialize


  def search_initialize
    @q = Idea.ransack(params[:q])
  end

  def generate_graph
    # ルートのアイデアとその子供を取得
    @problem = Idea.first

    # @problem が nil であることを確認
    return unless @problem

    # 新しいグラフを作成
    g = GraphViz.new(:G, type: :digraph, charset: 'UTF-8', fontname: 'Noto Sans CJK JP', fontsize: 18)

    # アイデアとその子供のノードとエッジを追加する再帰メソッドを定義
    def add_idea_and_children(graph, idea)
      # 現在のアイデアをノードとして追加
      node = graph.add_nodes(idea.name)
      # 現在のアイデアからその子供へのエッジを追加
      idea.children.includes([:children]).each do |child|
        child_node = add_idea_and_children(graph, child)
        graph.add_edges(node, child_node) if child_node # child_nodeがある場合のみ。
      end
      node
    end

    # ルートのアイデアから再帰メソッドを呼び出す
    add_idea_and_children(g, @problem)

    # 画像を生成
    @image_data = g.output(png: String)

    # 画像データをレスポンスとして送信
    send_data(@image_data, type: 'image/png', disposition: 'inline')
  end



  def index
    @problem = Idea.includes(:children).first
    @problem_children = @problem.children if @problem.present?
  end


  def search
    @q = Idea.ransack(params[:q])
    @ideas = @q.result(distinct: true)

    if @ideas.present?
      redirect_to solution_idea_path(@ideas.first.id)
    else
      flash[:notice] = "該当するアイデアが見つかりません。"
      redirect_back(fallback_location: root_path)
    end
  end


  def first_create
    name = params[:idea][:name]
    @problem = Idea.create(name: name)
    redirect_to first_solution_idea_path(@problem)
  end

  def create
    idea_params = params.require(:idea).permit(:parent_id ,name: [], parent_id: [])
    names = idea_params[:name].reject(&:blank?)
    this_idea_parent_id = params.dig(:idea, :parent_id)
    parent = Idea.find(this_idea_parent_id)
    names.each do |name|
      parent = Idea.find(this_idea_parent_id)
      @idea = parent.children.create(name: name)
    end
    refirect_to solution_idea_path(@problem) if this_idea_parent_id == @problem.id
    redirect_to request.referer, notice: '登録が完了しました'



  end


  def first_solution
    @theme = Idea.find_by(id: params[:id])
  end




  def solution
    @root_idea = Idea.select(:id, :name, :parent_id).find_by(id: params[:id])
    @theme = @root_idea.root
    @childlren_ideas = Idea.select(:id, :name).where(parent_id: @root_idea.id).includes(:children) if @root_idea.present?
  end


  def evaluate
    @all_solutions = Idea.where.not(id: Idea.pluck(:parent_id).compact).includes(:parent)
  end

  def set_easy_points
    @all_solutions = Idea.select(:id).where.not(id: Idea.pluck(:parent_id).compact)
    easy_points_params = params.require(:idea).permit!

    @all_solutions.each do |solution|
      easy_point = params["idea"][:"#{solution.id}_easy_point"].first
      idea = Idea.find_by(id: solution.id)
      idea.update(easy_point: easy_point)
    end

    redirect_to evaluate_ideas_path, notice: '①の評価が完了しました'
  end

  def set_effect_points
    @all_solutions = Idea.select(:id).where.not(id: Idea.pluck(:parent_id).compact)
    effect_points_params = params.require(:idea).permit!

    @all_solutions.each do |solution|
      effect_point = params["idea"][:"#{solution.id}_effect_point"].first
      idea = Idea.find_by(id: solution.id)
      idea.update(effect_point: effect_point)
    end

    redirect_to score_graph_ideas_path, notice: '②が完了しました'
  end


  def edit
    @idea = Idea.find_by(id: params[:id])
  end

  def update
    @idea = Idea.find_by(id: params[:id])
    if @idea.update(idea_params)
      redirect_to solution_idea_path(@idea.parent_id), notice: 'アイデアが更新されました。'
    else
      if @idea.parent.present?
        render :edit
      else
        redirect_to request.referer, notice: '変更しました'
      end
    end
  end

  def destroy
    @idea = Idea.includes(:children).find_by(id: params[:id])
    @idea_family = @idea.self_and_descendants
    @idea_family.each(&:destroy)
    redirect_to solution_idea_path(@idea.parent_id), notice: 'タスクが削除されました。'
  end

  def score_graph
    @all_solutions = Idea.where.not(id: Idea.pluck(:parent_id).compact)

    data = Idea.leaves.pluck(:name, :effect_point, :easy_point)
    @result = []
    data.each do |da|
     @result.push({name: da[0], data: [[da[1], da[2]]]})
    end
  end

  def ex_form
    @idea = Idea.find(params[:id])
    @child = @idea
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
