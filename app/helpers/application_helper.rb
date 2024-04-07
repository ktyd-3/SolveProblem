module ApplicationHelper

  def display_descendants(idea)
    list = ""
    if idea.children.any?
      idea.children.each do |child|
        list += "<div class='tree_list_line' id=\"list_#{child.id}\">"
        list += "&nbsp;" * (child.tree_level.to_i * 2) + "・" + link_to(child.name, solution_idea_path(child), data: { turbo_frame: "_top" }) + "<br>"
        list += "</div>"
        list += display_descendants(child)
      end
    end
    list
  end

  # 入力フォームを表示させるかどうか
  def permit_create(idea)
    if idea.user_id == @current_user.id
      return true
    else
      return false
    end
  end

end
