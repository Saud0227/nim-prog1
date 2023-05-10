require 'json'

if File.exists?("game_data.json")
    file = File.open("game_data.json", 'r')
    file_data = File.read("game_data.json")
    $save_game = JSON.parse(file_data)
    file.close()
    $save_game = $save_game["games"]
else
    $save_game = []
end

raw_configs = File.readlines("msg.txt")
i = 0
$configs = []
while i < raw_configs.length
    new_item = raw_configs[i].split(";")
    new_item[1] = new_item[1].split(",")
    $configs << new_item
    i += 1
end

p $configs.length

def main_menu()

    active = true
    menu_state = 0
    ls = 0


    while active


        # Skriver menu text
        if menu_state == 0
            puts "Main Menu"
            puts "Which mode do you want to play?"

            puts "(1): Single Player"
            puts "(2): Multiplayer"
            puts "(3): Load game"

        elsif menu_state == 1
            puts "How many players are there?"
        elsif menu_state == 2
            puts "What game would you like to finish? (q to go back)"
            i = 0

            keys = $save_game.keys()

            while i < keys.length
                item = $save_game[keys[i]]
                puts "\n"
                puts "ID: #{i}"
                puts "PLAYED: #{keys[i]}"
                puts "PLAYERS: "
                j = 0
                while j < item["players"].length
                    puts " - #{item["players"][j]}"
                    j += 1
                end
                puts "Pile: #{item["pile"]}"
                puts "Turn: #{item["players"][item["turn"]]}"
                if item["secret_flag"] != 0
                    puts "Secret: #{item["secret_flag"]}"
                end
                i += 1
            end

        elsif menu_state == 3
            puts "\n"
            puts "selected: #{ls}"
            puts "Want to load?"
            puts "(1): Yes"
            puts "(2): No"




        end


        # Tar input
        # -----------------------------------------------------
        # puts "\n"
        # om inget annant angivet
        if menu_state != 2
            c_input = await_user_input()
            puts "\n"
        end

        # Checkar om q
        if (c_input == "q" && menu_state == 0)
            raise Interrupt
        elsif (c_input == "q")
            menu_state = 0
            next
        end

        # Agerar olika beroende på menu
        if menu_state == 0
            # menu_state = menu_state.to_i

            if c_input == 1
                puts "LETS GO"
                $names = [get_players(1)[0]]
                active = false
            elsif c_input == 2
                menu_state = 1
                next
            elsif c_input == 3
                menu_state = 2
            end


        elsif menu_state == 1

            # Checka att vi har minst 1 spelare
            if (c_input < 1 || c_input > 13)
                puts "Please enter a integer between 1 and 13"
                next
            end
            $names = get_players(c_input)
            active = false

        elsif menu_state == 2
            c_input = gets.chomp.downcase
            if c_input == 'q'
                menu_state = 0
                next
            elsif c_input.to_i.to_s != c_input
                puts "Please enter number"
                next
            end

            c_input = c_input.to_i
            ls = c_input
            menu_state = 3

        elsif menu_state == 3
            if c_input != 1
                menu_state = 2
                next
            end
            item = $save_game[$save_game.keys[ls]]
            $save_game.delete($save_game.keys[ls])
            $names = item["players"]

            return item



        end

    end

end

def await_user_input()
    user_get = gets.chomp.downcase
    if user_get != "q"
        user_get = user_get.to_i
    end
    return user_get
end

def check_for_easter_egg()
    i = 0
    egg_array = []
    while i < $players.length
        egg = 1
        while egg < $configs.length
            j = 0
            while $players[i].downcase != $configs[egg][1][j] && j < $configs[egg][1].length
                j += 1
            end
            if $players[i].downcase == $configs[egg][1][j]
                egg_array << $configs[egg][0]
            end
            egg += 1
        end
        i += 1
    end

    i = 0
    while i < egg_array.length
        if egg_array[0] != egg_array[i]
            $egg_custom_msg = "How many sticks are you taking?"
            $egg_pile_name = "PILE"
            return nil
        end
    end
    j = 0
    while j < $configs.length
        if egg_array[0] == $configs[j][0]
            $egg_custom_msg = $configs[j][4]
            $egg_pile_name = $configs[j][3]
        end
    end

end



def get_players(num_players)
    curent_player_names = []
    i = 0
    while i < num_players
        puts "Player #{i+1}, whats your name?"
        c_in = gets.chomp
        if c_in.downcase == "q"

        end
        curent_player_names << c_in
        i += 1
    end
    return curent_player_names
end


def game_loop(save_game)
    turn = 0
    piles = Array.new(rand(1..5)) { rand(12..15) }
    if save_game != nil
        piles = save_game["pile"]
        turn = save_game["turn"]
    end
    use_bot = ($names.length == 1)

    if use_bot
        $names << "BOT"
    end

    # om ngn lallar och gör dum skit säger vi fuck you
    # pga save files
    if $names[-1] == 'BOT'
        # Det detta gör är att om ngn är dum och kör multiplayer men heter bot
        # Så blir det ett singelplayer spel
        # Finns anledningar för detta
        use_bot = true
    end
    bot_diff = 1

    puts "--PLAYERS--"
    i = 0
    while i < $names.length
        puts $names[i]
        i += 1
    end

    while true
        while piles.length > 0
            while turn < $names.length
                puts "PILES: #{piles}"
                if use_bot && (turn == 1)
                    b_pile, b_take = bot_turn(piles, bot_diff)
                    puts "#{$names[turn]} took #{b_take} from #{b_pile + 1}"
                    piles[b_pile] -= b_take
                else
                    puts "Which pile would you like to pick from?"
                    pile = choose_pile(piles)
                    puts "There are #{piles[pile-1]} stick in pile number: #{pile}."

                    puts "How many sticks are you taking #{$names[turn]} choose between 1 and 3."
                    piles[pile-1] -= player_turn(piles[pile-1])
                end
                i = 0
                while i < piles.length
                    if piles[i] == 0
                        piles.delete_at(i)
                    end
                    i += 1
                end
                if piles.length == 0
                    if use_bot
                        $names.pop(1)
                    end
                    p $names
                    return turn
                end
                turn += 1
            end
            turn = 0
        end
    end
end

def choose_pile(piles)
    pile = await_user_input()
    if pile == 'q'
        raise Interrupt
    end
    while pile < 1 || pile > piles.length
        puts "Please choose an existing pile, choose between 1 and #{piles.length}"
        pile = await_user_input()
    end
    return pile
end

def player_turn(c_value)
    amount_of_sticks = await_user_input()
    if amount_of_sticks == "q"
        raise Interrupt
    end
    while (amount_of_sticks.to_i < 1) || (amount_of_sticks.to_i > ([3, c_value].min))
        if amount_of_sticks != "0" && amount_of_sticks.to_i == 0
            puts "Please send in a whole number between 1-#{[3, c_value].min}"
            amount_of_sticks = gets.chomp.to_i
        else
            puts "You tried to take #{amount_of_sticks} sticks. Please choose between 1-#{[3, c_value].min} sticks."
            amount_of_sticks = gets.chomp.to_i
        end
    end
    return amount_of_sticks.to_i
end


def bot_turn(c_data, diff)
    if diff == 2 or diff == 3
        if c_data.length == 3
            i = 0
            if c_data[0] < c_data[1]
                i = 1
            end
            if c_data[i] < c_data[2]
                i = 2
            end
            pile_to_take = i

            sticks = [3, c_data[i]].min
            return pile_to_take, sticks
        elsif c_data.length == 2
            if c_data[0] < c_data[1]
                i = 1
            else
                i = 0
            end
            pile_to_take = i

            sticks = [3, c_data[i]].min
            return pile_to_take, sticks
        else
            game_states = [
                [0], # 0 [Error happend]
                [1], # 1 [Loss]
                [1], # 2 [win
                [2], # 3 [win]
                [3], # 4 [win]
                [1], # 5 [loss]
                [1], # 6 [force into a1]
                [2], # 7 [force into a1]
                [3], # 8 [force into a1]
                [1], # 9 [loss]
                [1], # 10 [force into a2]
                [2], # 11 [force into a2]
                [3], # 12 [force into a2]
                [1], # 13 [loss]
                [1], # 14 [force into a2]
                [2], # 15 [force into a2]
            ]
            return 0, game_states[c_data[0]]
        end
    elsif diff == 1
        pile_to_take = rand(0..c_data.length)
        sticks = rand(1..([3, c_data[pile_to_take]].min))
        return pile_to_take, sticks
    end
end


def game_over(loser = nil)

    menu_state = 0
    if loser != nil
        puts "The loser was #{$names[loser]}!"
        puts "-------------------------------"
    end

    while true

        # Print text

        if menu_state == 0
            puts "Would you like to play again?"
            puts "(1): Yes"
            puts "(2): No"

        elsif menu_state == 1
            puts "Do you want the same configuration or another?"
            puts "(1): Same settings"
            puts "(2): Different settings"
        end

        # Hanlde input
        c_input = await_user_input()

        # check q
        if (c_input == "q" && menu_state == 0)
            return 0
        elsif (c_input == "q")
            menu_state = 0
            next
        end

        # Menue specifik
        if menu_state == 0
            if !(c_input == 1 || c_input == 2)
                puts "Please enter a valid input, 1 or 2."
                next
            end
            if c_input == 1
                menu_state = 1
            else
                return 0
            end
        elsif menu_state == 1

            if !(c_input == 1 || c_input == 2)
                puts "Please enter a valid input, 1 or 2."
                next
            end

            if c_input == 1
                return 1
            elsif c_input == 2
                return 0
            end
        end
    end
end




def main_loop()

    $game_state = 0
    $names = []
    $egg_pile_name = ""
    $egg_custom_msg = ""


    # starup

    # load game data?
    # skriver ngt
    begin
        while true
            loser = nil

            if $game_state == 0
                load_game = main_menu()

                $game_state = 1
                system("cls")
            end

            if $game_state == 1
                loser = game_loop(load_game)
                load_game = nil
                $game_state = 2
                system("cls")
            end

            if $game_state == 2
                $game_state = game_over(loser)
                system("cls")
            end



        end

    rescue Interrupt
        if $game_state == 1
            print("!")
        end

        file = File.open("game_data.json", 'w')
        file.write(JSON.pretty_generate({"games" => $save_game}))
        # p $save_game
        # p JSON.pretty_generate($save_game)
        # file.write("test")
        file.close()
    # rescue NoMethodError
    #     puts "NoMethodError caught"
    #     puts "If you were loading files when this error ocured, there is a posibility that your game data file is corupted"
    #     puts "Try deleting your file to resolv"
    end
end


main_loop()