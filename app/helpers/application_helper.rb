module ApplicationHelper

  def display_descendants(idea)
    list = ""
    if idea.children.any?
      idea.children.each do |child|
        list += "&nbsp;" * (child.tree_level.to_i * 2) + "・" + link_to(child.name, solution_idea_path(child), data: { turbo_frame: "_top" }) + "<br>"
        list += display_descendants(child)
      end
    end
    list
  end

end
