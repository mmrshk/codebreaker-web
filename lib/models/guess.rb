class Guess
  FAIL_DIGIT_CHAR = 'x'.freeze
  attr_reader :game, :guess_code

  def handle_guess_code(game, guess_code)
    @game = game
    @guess_code = guess_code
    return start_process if valid_size?(game, guess_code)

    code = start_process
    code_size = start_process.size

    while code_size != Codebreaker::Entities::Game::DIGITS_COUNT
      code += FAIL_DIGIT_CHAR
      code_size += 1
    end

    code
  end

  private

  def valid_size?(game, guess_code)
    start_process.size == Codebreaker::Entities::Game::DIGITS_COUNT
  end

  def start_process
    game.start_process(guess_code)
  end
end
