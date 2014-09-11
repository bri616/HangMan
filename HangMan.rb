class HangMan
  require 'colorize'
  require 'set'
  attr_accessor :secret_word, :letters_tried, :screen, :incorrect_letters, :correct_letters, :exit_message
  def initialize
    @letters_tried = []
    @incorrect_letters = []
    @correct_letters = []
    @secret_word = choose_random_word
    @screen = Screen.new()
    @exit_message = exit_message
  end

  def choose_random_word
    word_array = ["chinook", "cascade", "columbus"]
    word_array[rand(word_array.length)]
  end

  def ask_for_letter
    print "Choose a new letter: "
    new_letter = gets.chomp.downcase
    alphabet = ("a".."z").to_a
    if alphabet.include? new_letter
      check_for_letter(new_letter)
    else
      redraw_hangman
      puts "Not allowed.".magenta
      ask_for_letter
    end
  end

  def check_for_letter(new_letter)
    if !@letters_tried.include? new_letter
      add_letter(new_letter)
    else
      redraw_hangman
      puts "Already tried that one.".magenta
      ask_for_letter
    end
  end

  def add_letter(new_letter)
    letters_tried << new_letter
    if correct_letter?(new_letter)
      @correct_letters << new_letter
    else
      @incorrect_letters << new_letter
      @screen.redraw(@incorrect_letters.count-1)
    end
  end

  def correct_letter?(new_letter)
    @secret_word.chars.include? new_letter
  end

  def incorrect_letters_formatted
    alphabet = ("a".."z").to_a
    format_string = " "*alphabet.length
    format_letters_for_display(incorrect_letters, alphabet,format_string).red
  end

  def correct_letters_formatted
    theword = @secret_word.chars
    format_string = "_ "*theword.length
    format_letters_for_display(correct_letters, theword, format_string, 1).green
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
    puts incorrect_letters_formatted
    puts correct_letters_formatted
  end

  def over?
    if @correct_letters.to_set == @secret_word.chars.to_set
      puts "You won!"
      @exit_message = "You won!"
      true
    elsif @incorrect_letters.length == @screen.error_bank.length
      @exit_message = "You lost! :("
      true
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

    def randomly_colorize(error_str)
      error_str.colorize(String.colors.shuffle.first)
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
        j: "                ",
        k: "                "
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
end

def run
  hangman_game = HangMan.new
  while true
    hangman_game.redraw_hangman
    hangman_game.ask_for_letter
    if hangman_game.over?
      hangman_game.redraw_hangman
      puts "Game Over."
      puts hangman_game.exit_message
      break
    end
  end
end

run
