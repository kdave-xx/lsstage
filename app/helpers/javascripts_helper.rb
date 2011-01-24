module JavascriptsHelper
  def highlight_last_child(page, element)
    page << <<-END_JS
      $('#{element.to_s}').childElements().last().highlight();
    END_JS
  end
end
