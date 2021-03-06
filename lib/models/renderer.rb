class Renderer
  def stats_view
    template('statistics.html.erb')
  end

  def lose_view
    template('lose.html.erb')
  end

  def error404_view
    template('error404.html.erb')
  end

  def rules_view
    template('rules.html.erb')
  end

  def game_view
    template('game.html.erb')
  end

  def menu_view
    template('menu.html.erb')
  end

  def win_view
    template('win.html.erb')
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
