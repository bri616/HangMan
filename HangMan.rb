class HangMan
  require 'colorize'
  require 'set'
  attr_accessor :letters_tried, :screen, :incorrect_letters, :correct_letters, :exit_message, :screen_message
  def initialize
    @letters_tried = []
    @incorrect_letters = []
    @correct_letters = []
    @secret_word = choose_random_word
    @screen = Screen.new()
  end

  def choose_random_word
    word_array.sample.chomp
  end

  def word_array
    File.readlines("/usr/share/dict/words")
  end

  def check_guess(letter)
    check_word_for_letter(letter) if in_alphabet? letter
  end

  def update_scrn_msg(letter)
    if !in_alphabet? letter
      @screen_message = "Not allowed!".cyan
    elsif @letters_tried.include? letter
      @screen_message = "Already tried it!".magenta
    else
      @screen_message = ""
    end
  end


  def in_alphabet?(letter)
    ("a".."z").to_a.include? letter
  end

  def check_word_for_letter(new_letter)
    add_letter(new_letter) if !@letters_tried.include? new_letter
  end

  def add_letter(new_letter)
    letters_tried << new_letter
    add_to_correct_letters(new_letter) if correct_letter?(new_letter)
    add_to_incorrect_letters(new_letter) if !correct_letter?(new_letter)
  end

  def add_to_correct_letters(new_letter)
    @correct_letters << new_letter
  end

  def add_to_incorrect_letters(new_letter)
    @incorrect_letters << new_letter
    @screen.redraw(error_number)
  end

  def correct_letter?(new_letter)
    @secret_word.chars.include? new_letter
  end

  def error_number
    @incorrect_letters.count-1
  end

  def incorrect_letters_formatted
    alphabet = ("a".."z").to_a
    format_string = " "*alphabet.length
    format_letters_for_display(incorrect_letters, alphabet,format_string).red
  end

  def correct_letters_formatted
    theword = @secret_word.chars
    format_string = "_ "*theword.length
    format_letters_for_display(@correct_letters, theword, format_string, 1).green
  end

  def format_letters_for_display(input_letters, poss_letters, format_string, space_val=0)
    input_letters.each do |a|
      theinds = poss_letters.each_index.select{|i| poss_letters[i] == a}
      theinds.each do |i|
        format_string[i*(space_val+1)] = a
      end
    end
    format_string
  end

  def redraw_hangman
    puts "\e[H\e[2J"
    @screen.display
    puts @screen_message
    puts incorrect_letters_formatted
    puts correct_letters_formatted
  end

  def over?
    if @correct_letters.to_set == @secret_word.chars.to_set
      @exit_message = "You won!"
      true
    elsif @incorrect_letters.length == @screen.error_bank.length
      @correct_letters = @secret_word.chars
      @exit_message = "You lost! :("
      true
    end
  end
end

class Screen
  attr_accessor :picture

  def initialize
    @picture = blank_screen
  end

  def redraw(error_number)
      error_row = error_bank[error_number][:row]
      error_col = error_bank[error_number][:col]
      error_str = error_bank[error_number][:str]
      @picture[error_row][error_col ] = randomly_colorize(error_str)
  end

  def randomly_colorize(input_str)
    input_str.colorize(String.colors.sample)
  end

  def display
    @picture.each do |*,line|
      puts line
    end
  end

  def blank_screen
      {
      a: "  |             ",
      b: "  |--------|    ",
      c: "  |             ",
      d: "  |             ",
      e: "  |             ",
      f: "  |             ",
      g: "  |     _______ ",
      h: "__|____________ ",
      j: "                "
      }
  end

  def error_bank
    [
      {
        id: :head,
        row: :c,
        col: 11,
        str: "O"
      },
      {
        id: :arm1,
        row: :d,
        col: 12,
        str: "-"
      },
      {
        id:  :body1,
        row: :d,
        col: 11,
        str: "|"
      },
      {
        id: :arm2,
        row: :d,
        col: 10,
        str: "-"
      },
      {
        id: :body2,
        row: :e,
        col: 11,
        str: "|"
      },
      {
        id: :leg1,
        row: :f,
        col: 12,
        str: "\\"
      },
      {
        id: :leg2,
        row: :f,
        col: 10,
        str: "/"
      },
    ]
  end
end

def run
  hangman_game = HangMan.new
  until hangman_game.over?
    hangman_game.redraw_hangman
    print "Guess a letter: "
    letter = gets.chomp.downcase
    hangman_game.update_scrn_msg(letter)
    hangman_game.check_guess(letter)
  end
  hangman_game.redraw_hangman
  puts "Game Over."
  puts hangman_game.exit_message
end

run
