module Hangman

  require 'yaml'

  MAX_GUESSES = 8
  DICTIONARY_FILE = "./5desk.txt"

  class Game

    class <<self
      attr_accessor :dictionary
    end

    attr_accessor :wordToGuess, :usedLetters, :wrongGuesses

    def to_yaml
    YAML.dump (self)
    end

    def self.from_yaml(string)
      object = YAML.load string
    end


    def initialize usedLetters, wrongGuesses, wordToGuess
      #@wordToGuess = Game.getWord.downcase
      @wrongGuesses = wrongGuesses
      @usedLetters = usedLetters
      @wordToGuess = wordToGuess
    end

    def play
      until won? || lost?
        display_status

        if save_instead_of_guessing?
          save_game
          return
        else
          guess = prompt_for_guess #need to make
        end

        unless in_word?(guess)
          @wrongGuesses += 1
        end
        add_to_used_letters(guess)
      end

      if won?
        puts "congratulations!  You guessed the word #{wordToGuess}"
      else
        puts "Sorry!  You couldn't guess the word!  Here is what managed to uncover:"
        display_word
      end
    end


    def display_status
      display_word
      puts "Used letters: #{usedLetters.join(" ")}"
      puts "Guesses remaining: #{MAX_GUESSES - wrongGuesses}"
    end

    def self.create_game
      if self.restore_from_save? #restoreFromSave? #need to make
        hangman = self.load_game #need to make
      else
        hangman = Game.new([],0, self.get_word)
      end
    end



    private

    def save_instead_of_guessing?
        puts "Would you like to save the game now, and continue later?  enter 'y' to save, and anything else to continue"
        return gets.chomp.downcase == 'y'
    end

    def self.restore_from_save?
      puts "Would you like to load an existing game?" "enter 'y' to load existing game, and anything else to begin a new game"
      return gets.chomp.downcase == 'y'
    end

    def save_game
      dataToSave = self.to_yaml
      File.open("saved_game.yaml", "w"){|file|
        file.write self.to_yaml
        puts "saved game and exited.  Load game the next time you play to continue from where you left off."
      }
    end

    def self.load_game
      begin
        File.open("saved_game.yaml", "r"){|file|
          return YAML.load (file)
        }
      rescue
        puts "file not found: loading new game instead:"
        return Game.new([],0,self.get_word)
      end
    end


    def display_word #shows the word based on the guesses so far
      wordToGuess.each_char {|char|
        if usedLetters.include?(char)
          print "#{char} "
        else
          print "_ "
        end
      }
      puts "."
    end

    def add_to_used_letters letter
      usedLetters << letter
      usedLetters.sort!
    end

    def prompt_for_guess #get guess from player, check to make sure it's a single character and hasn't been guessed
      guess = ""
      loop{
        puts "Please enter a single letter to guess: (e.g., 'a')"
        guess = gets.chomp.downcase

        unless ("a".."z").to_a.include?(guess)
          puts "Your guess must be a letter of the alphabet"
          next
        end

        if usedLetters.include?(guess)
          puts "'#{guess}' has already been guessed.  Please select a different letter"
          next
        else
          break
        end
      }
      return guess
    end

    def in_word? guess  #check to see if guess is in word
      wordToGuess.include?(guess)
    end

    def won? #see if the word has been completely revealed
      wordToGuess.split("").all? {|char| usedLetters.include?(char)}
    end

    def lost?
      return wrongGuesses >= MAX_GUESSES
    end

    def self.get_word
      if Game.dictionary.nil?
        Game.dictionary = Game.load_dictionary DICTIONARY_FILE
      end
      filtered_list = Game.dictionary.filter {|word| word.length >= 5 && word.length <= 12}
      filtered_list.sample
    end


    def self.load_dictionary dictionaryFile
      dictionary = []
      File.open(dictionaryFile,'r') do |file|
        until file.eof?
          dictionary << file.gets.chomp
        end
      end
      return dictionary
    end
  end

  hangman = Game.create_game
  hangman.play
end

