module ApplicationHelper
  def login_link
    login_path + "?return_to=" + request.env['PATH_INFO']
  end

  def markdown(text)
    markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, space_after_headers: true)
    markdown.render(text).html_safe
  end
end
