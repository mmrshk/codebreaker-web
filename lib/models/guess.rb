class Guess
  FAIL_DIGIT_CHAR = 'x'.freeze

  def handle_guess_code(game, guess_code)
    return game.start_process(guess_code) if valid_size?(game, guess_code)

    code = game.start_process(guess_code)
    code_size = game.start_process(guess_code).size

    while code_size != Codebreaker::Entities::Game::DIGITS_COUNT
      code += FAIL_DIGIT_CHAR
      code_size += 1
    end

    code
  end

  private

  def valid_size?(game, guess_code)
    game.start_process(guess_code).size == Codebreaker::Entities::Game::DIGITS_COUNT
  end
end
