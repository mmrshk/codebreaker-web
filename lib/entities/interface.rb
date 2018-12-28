class Interface
  include Codebreaker::
  attr_reader :request

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @render = Renderer.new
    #expand_score_class
  end

  def response
    case request.path
    when '/' then menu
    when '/rules' then rules
    when '/play' then play
    when '/show_hint' then show_hint
    when '/submit_answer' then submit_answer
    when '/finish_game' then finish_game
    when '/top_scores' then top_scores
    else @render.error404
    end
  end

  def menu
    #request.session.clear
    @render.menu
  end

  def rules
    @render.rules
  end

  def play
    binding.pry
    @request.session[:game] = Codebreaker::Game.new(@request.params['player_name'], @request.params['level'])
    @request.session[:hints] = []
    template('game.html.erb')
  end
end
