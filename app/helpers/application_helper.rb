module ApplicationHelper

  def display_descendants(idea)
    list = ""
    if idea.children.present?
      idea.children.each do |child|
        list += "<div class='tree_list_line' id=\"list_#{child.id}\">"
        list += "&nbsp;" * (child.tree_level.to_i * 2) + "- " + link_to(child.name, solutions_idea_path(child), data: { turbo_frame: "_top" }) + "<br>"
        list += "</div>"
        list += display_descendants(child)
      end
    end
    list
  end

  def display_checkbox_ideas_family(idea, form)
    line = ""
    if idea.children.present?
      idea.children.each do |child|
        line += "&nbsp;" * (child.tree_level.to_i * 4) +  form.check_box(:id ,{:multiple => true}, child.id, false) + child.name + "<br>"
        # debugger
        line += display_checkbox_ideas_family(child, form)
      end
    end
    line
  end

  def indent_tree_lebel(idea)
    @idea = Idea.find_by(id: idea)
    list = ""
    list += "&nbsp;" * (@idea.tree_level.to_i * 4)
    list
  end

  def permit_user?(idea)
    if idea.user_id == @current_user.id
      return true
    else
      return false
    end
  end

  def announce_evaluation_ideas_when_over_17_ideas
    flash[:notice] = 'これはフラッシュメッセージです！'
  end

end
