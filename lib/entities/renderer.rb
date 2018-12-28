class Renderer
  def message(phrase)
    I18n.t(phrase)
  end

  def error404
    template('error404.html.erb')
  end

  def rules
    template('rules.html.erb')
  end

  def menu
    template('menu.html.erb')
  end

  def template(erb_name)
    Rack::Response.new(render(erb_name))
  end

  private

  def render(template)
    path = File.expand_path("../../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
end
