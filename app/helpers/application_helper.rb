module ApplicationHelper
  def display_descendants(idea)
    list = ""
    if idea.children.any?
      idea.children.each do |child|
        list += "&nbsp;" * (child.tree_level.to_i * 2)  +  child.name + "<br>"
        list += display_descendants(child)
      end
    end
    list
  end
end
