require 'csv'

class Game
    attr_reader :player
    attr_accessor :words, :dictionary, :secret_word, :guess_list, :guess, :incorrect_guess, :incorrect_guesses, :wins, :loss

    def initialize(player)
        @player = player # Contains the User's name
        @incorrect_guess = 3 #How many tries the user has to guess the word
        @secret_word = "" #What the word to guess is
        @guess = "" #what the user's guess is
        @incorrect_guesses = [] #List of all the incorrect guesses. This version allows the person to guess wrong more than once. hard mode :D
        @wins = 0 #How many times the user wins
        @loss = 0 #How many times the user loses
    end

    def generateGame(answer)

        #load in data from saved csv file 
        if answer.downcase.match?("continue")
            puts "\nContinuing from saved file\n"   
            self.words = CSV.open('./saves/save.csv', headers:true, header_converters: :symbol)
            words.each do |word|
                self.secret_word = word[:secret_word]
                self.guess_list = word[:guess_list].split(//)
                self.incorrect_guess = Integer(word[:incorrect_guess])
                self.incorrect_guesses = word[:incorrect_guesses].split(//) 
            end
            puts "\nHere are the letters you have currently guessed on the word."
            guess_list.each {|e| print e.downcase + " "}
            puts "\nHere are the incorrect letters you have guessed"
            incorrect_guesses.each {|e| print e + ", " }

        #pull in new word and start fresh        
        elsif answer.downcase.match?("new")
            puts "\nStarting new game..."
            self.words = File.readlines("words.txt")
            self.dictionary = words.select{|word| (word.length > 5 && word.length < 13)}
            self.secret_word = dictionary.sample.chomp
            self.guess_list = Array.new(secret_word.length, "_")
            self.incorrect_guess = 3
            self.incorrect_guesses = []

        #quiting the game manually
        elsif answer.downcase.match?("exit")
            gameover()
        #Error on user input
        
        else
            puts "Please enter 'continue', 'new', or 'exit'"
            answer = gets.chomp
            generateGame(answer)
        end
    end

    ### Sanitizes the user input and also checks if they are trying to save their game
    def guess()
        guess = gets.chomp
        if guess.downcase == "save"
            guess
        elsif guess[0].match?('^[a-zA-Z]+$')
            guess[0]
        else
            puts "Sorry, that was not a letter.\nPlease enter a letter only."
            guess()
        end
    end

    ### Checks if the letter is part of the word or not
    def compare(guess)
        correct_guess = 0
        0.upto(@secret_word.length) { |i|
            if guess == @secret_word.downcase[i]
                @guess_list[i] = guess 
                correct_guess+= 1
            end
        }
        if correct_guess == 0
            puts "\nYikes! There was no #{guess}(s) in the word."
            self.incorrect_guesses.push(guess)
            print "Bad guesses: "
            incorrect_guesses.each {|e| print e + ", " }
            self.incorrect_guess-=1
            puts "\nBe careful, you only have #{incorrect_guess} guesses left!"
        else
            puts "\nNice! There were #{correct_guess} #{guess}'s in your word."
            guess_list.each {|e| print e.downcase + " "}
        end
    end

    ### Checks if every letter has been found
    def winner?()
        @guess_list.include?("_")
    end

    ### Deals with saving to the csv file
    def save?(guess)
        if guess.downcase.match?("save") 
            puts "Saving file now..."
            CSV.open("./saves/#{player.name}_save.csv", "w") do |csv|
                csv << ["secret_word","guess_list","incorrect_guess","incorrect_guesses"]
                csv << [secret_word,guess_list.join(''),incorrect_guess.to_s,incorrect_guesses.join('')]
            end
            gameover()
        end 
    end

    ### Starts the actual game to be played
    def play()
        puts "\nWould you like to continue from a saved game or start a new one? (continue or new)\nEnter in (exit) if you would like to quit playing."
        answer = gets.chomp
        generateGame(answer)
        puts "Your word has #{secret_word.length} letters. You have #{incorrect_guess} incorrect guesses before you fail.\nGood Luck!!"
        
        until incorrect_guess == 0
            puts "\nEnter in your guess, or type (save) to save your game:"
            self.guess = guess()
            save?(@guess)
            compare(@guess)
            if !winner?()
                self.wins+=1
                puts "\nCongrats #{player.name}!! You guessed #{secret_word} correctly!\nAnd with #{incorrect_guess} guesses left too!"
                play()
            end
        end
        
        self.loss+=1
        puts "\nYou Lose. The word was #{secret_word}.\nDang, better luck next time!"
        play()
    end

    ### Helps to output the scoreboard, add the thank you for playing msg to the player, and exit safely
    def gameover()
        puts "\n******* SCOREBOARD *********\n#{player.name}"
        puts "Wins: #{wins}\nLosses: #{loss}"
        puts "Thanks for playing!!!"
        exit
    end

end

### Can track the individual player for game saves if I wanted, and could attach their overall wins & losses to be fancier
class Player
    attr_reader :name
    def initialize(name)
        @name = name
    end
end

### Where the game is actually started ###

puts "Enter your name: "
name = gets.chomp
player = Player.new(name)
game = Game.new(player)
game.play()




