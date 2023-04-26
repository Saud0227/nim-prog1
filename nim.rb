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

p $configs

def main_menu()

    active = true
    menu_state = 0


    while active


        # Skriver menu text
        if menu_state == 0
            puts "Main Menu"
            puts "Wich mode do you want to play?"

            puts "(1): Single Player"
            puts "(2): Multiplayer"
            puts "(3): Load game"

        elsif menu_state == 1
            puts "How many players are there?"
        elsif menu_state == 2
            puts "What game would you like to finish? (q to go back)"
            i = 0

            while i < $save_game.length
                puts "\n"
                puts "GAME NMR: #{i}"
                puts "PLAYERS: "
                j = 0
                while j < $save_game[i]["players"].length
                    puts " - #{$save_game[i]["players"][j]}"
                    j += 1
                end
                puts "Pile: #{$save_game[i]["pile"]}"
                puts "Turn: #{$save_game[i]["players"][$save_game[i]["turn"]]}"
                if $save_game[i]["secret_flag"] != 0
                    puts "Secret: #{$save_game[i]["secret_flag"]}"
                end
                i += 1
            end
        end


        # Tar input
        # -----------------------------------------------------
        # puts "\n"
        c_input = await_user_input()
        puts "\n"


        # Checkar om q
        if (c_input == "q" && menu_state == 0)
            raise Interrupt
        elsif (c_input == "q")
            menu_state = 0
            next
        end

        # Agerar olika beroende på menu
        if menu_state == 0
            menu_state = menu_state.to_i

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
    # config_names = $configs[2].split
    # i = 0
    # while i < $names.length
    #   j = 0
    #   while j < config_names.length
    # Vi har tre arrayer, vi behöver kolla alla namn för alla confignamn i alla olika configs
end
    


def get_players(num_players)
    curent_player_names = []
    i = 0
    while i < num_players
        puts "Player #{i+1}, whats your name?"
        c_in = gets.chomp
        if c_in.downcase == "q"

        end
        curent_player_names << 
        i += 1
    end
    return curent_player_names
end

def game_loop()
    turn = 0
    pile = rand(12..15)
    use_bot = ($names.length == 1)

    if use_bot
        $names << "BOT"
    end
    bot_diff = 3

    puts "--PLAYERS--"
    i = 0
    while i < $names.length
        puts $names[i]
        i += 1
    end

    while true
        while pile > 0
            while turn < $names.length
                puts "PILE: #{pile}"
                if use_bot && (turn == 1)
                    b_move = bot_turn(pile, bot_diff)
                    puts "#{$names[turn]} played #{b_move}"
                    pile -= b_move
                else
                    puts "How many sticks are you taking #{$names[turn]} choose between 1 and 3."
                    pile -= player_turn(pile)
                end
                if pile == 0
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
    game_states = [
        [0, 0, 0], # 0 [Error happend]
        [1, 1, 1], # 1 [Loss]
        [1, 1, 1], # 2 [win
        [2, 1, 1], # 3 [win]
        [3, 3, 2], # 4 [win]
        [1, 2, 2], # 5 [loss]
        [1, 1, 3], # 6 [force into a1]
        [2, 1, 1], # 7 [force into a1]
        [3, 3, 2], # 8 [force into a1]
        [1, 1, 4], # 9 [loss]
        [1, 3, 2], # 10 [force into a2]
        [2, 2, 1], # 11 [force into a2]
        [3, 3, 4], # 12 [force into a2]
        [1, 3, 2], # 13 [loss]
        [1, 1, 2], # 14 [force into a2]
        [2, 1, 3], # 15 [force into a2]
    ]
    return game_states[c_data][3-diff]
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


    # starup

    # load game data?
    # skriver ngt
    begin
        while true
            loser = nil

            if $game_state == 0
                main_menu()
                $game_state = 1
                system("cls")
            end

            if $game_state == 1
                loser = game_loop()
                $game_state = 2
                system("cls")
            end

            if $game_state == 2
                $game_state = game_over(loser)
                system("cls")
            end



        end

    rescue Interrupt


        # save curent game (if any)
        print("!")

    end
end


main_loop()