class IdeasController < ApplicationController
  require "ruby-graphviz"
  before_action :set_current_user,:search_initialize, :autheniticate_user
  before_action :get_generation, only: [:evaluate, :set_easy_points,:set_effect_points,:score_graph]
  # アイデアへの閲覧制限
  before_action :autheniticate_ideas, except: [:theme,:first_create,:create]




  def set_current_user
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id].present?
  end

  # ログインしてない場合のアクセス制限
  def autheniticate_user
    if @current_user == nil
      flash[:notice] = "ログインが必要です"
      redirect_to login_ideas_path
    end
  end

  def autheniticate_ideas
    @idea = Idea.find_by(id: params[:id])
    if @idea.user_id != @current_user.id
      redirect_to root
      flash[:notice] = "権限がありません。"
    end
  end


  def first_create
    name = params[:idea][:name]
    @theme = Idea.create(name: name, user_id: @current_user.id)
    redirect_to first_solution_idea_path(@theme)
  end

  def get_generation
    @theme = Idea.find_by(id: params[:id])
    # 子アイデアを持たないアイデアすべてを取得
    @leaf_descendants = @theme.descendants.select(&:leaf?)
  end


  def tree
    @theme = Idea.find_by(id: params[:id])
  end


  def search_initialize
    @q = Idea.ransack(params[:q])
  end

  def generate_graph
    # ルートのアイデアとその子供を取得
    @problem = Idea.find_by(id: params[:id])

    # @problem が nil であることを確認
    return unless @problem

    # 新しいグラフを作成
    g = GraphViz.new(:G, type: :digraph, charset: 'UTF-8', fontname: 'Noto Sans CJK JP', fontsize: 18)

    # アイデアとその子供のノードとエッジを追加する再帰メソッドを定義
    def add_idea_and_children(graph, idea)
      # 現在のアイデアをノードとして追加
      node = graph.add_nodes(idea.name)
      # 現在のアイデアからその子供へのエッジを追加
      idea.children.each do |child|
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
    @theme = Idea.find_by(id: params[:id])
    @ideas = @q.result(distinct: true)

    if @ideas.present?
      # @ideasから@themeの子孫アイデアのみを取得
      matching_ideas = @ideas.select { |idea| @theme.descendants.include?(idea) }

      if matching_ideas.present?
        redirect_to solution_idea_path(matching_ideas.first.id)
      else
        flash[:notice] = "該当するアイデアは解決したいテーマ内にありません。"
        redirect_back(fallback_location: root_path)
      end
    else
      flash[:notice] = "該当するアイデアが見つかりません。"
      redirect_back(fallback_location: root_path)
    end
  end



  def create
    idea_params = params.require(:idea).permit(:parent_id ,name: [], parent_id: [])
    names = idea_params[:name].reject(&:blank?)
    this_idea_parent_id = params.dig(:idea, :parent_id)
    parent = Idea.find(this_idea_parent_id)
    names.each do |name|
      parent = Idea.find(this_idea_parent_id)
      parent.children.create(name: name,user_id: @current_user.id)
    end
    if parent.root?
      redirect_to solution_idea_path(parent), notice: '登録が完了しました'
    else
      redirect_to request.referer, notice: '登録が完了しました'
    end
  end


  def first_solution
    @theme = Idea.find_by(id: params[:id])
  end


  def theme
    @themes = Idea.where(parent_id: nil,user_id: @current_user.id) if @current_user.present?
  end


  def solution
    @root_idea = Idea.find_by(id: params[:id])
    @theme = @root_idea.root
    @children_ideas = @root_idea.children.select(:id, :name) if @root_idea.present?
  end


  def evaluate
    @theme = Idea.find_by(id: params[:id])
    # 子アイデアを持たないアイデアすべてを取得
    @leaf_descendants = @theme.descendants.select(&:leaf?)
    @last_idea = @leaf_descendants.last
  end

  def set_easy_points
    easy_points_params = params.require(:idea).permit!

    @leaf_descendants.each do |solution|
      easy_point = params["idea"][:"#{solution.id}_easy_point"].first
      idea = Idea.find_by(id: solution.id)
      idea.update(easy_point: easy_point)
    end

    redirect_to evaluate_idea_path(@theme), notice: '①の評価が完了しました'
  end

  def set_effect_points
    effect_points_params = params.require(:idea).permit!

    @leaf_descendants.each do |solution|
      effect_point = params["idea"][:"#{solution.id}_effect_point"].first
      idea = Idea.find_by(id: solution.id)
      idea.update(effect_point: effect_point)
    end

    redirect_to score_graph_idea_path(@theme), notice: '②が完了しました'
  end


  def score_graph
    data = @leaf_descendants.pluck(:name, :effect_point, :easy_point)
    @result = []
    data.each do |da|
      @result.push({name: da[0], data: [[da[1], da[2]]]})
    end
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
    @idea = Idea.find_by(id: params[:id])
    @idea_parent = @idea.parent
    @idea_family = @idea.self_and_descendants
    @idea_family.each(&:destroy)
    redirect_to request.referer, notice: 'タスクが削除されました。'

  rescue ActiveRecord::RecordNotFound => e
    redirect_to solution_idea_path(@idea_parent), notice: 'タスクが削除されました。'

  end

  # solutionでは削除後同じページ
  def destroy_solution
    @idea = Idea.find_by(id: params[:id])
    @idea_parent = @idea.parent
    @idea_family = @idea.self_and_descendants
    @idea_family.each(&:destroy)
    redirect_to request.referer, notice: 'タスクが削除されました。'
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
