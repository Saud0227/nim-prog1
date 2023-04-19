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

        elsif menu_state == 1
            puts "How many players are there?"
        end

        # Tar input
        # -----------------------------------------------------
        c_input = await_user_input()


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
            end


        elsif menu_state == 1

            # Checka att vi har minst 1 spelare
            if (c_input < 1 || c_input > 13)
                puts "Please enter a intiger between 1 and 13"
                next
            end
            $names = get_players(c_input)
            active = false
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


def get_players(num_players)
    curent_player_names = []
    i = 0
    while i < num_players
        puts "Player #{i+1}, whats your name?"
        curent_player_names << gets.chomp
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
    while true
        while pile > 0
            while turn < $names.length
                if pile == 1
                    #Enter gameover screen with "stats"
                end
                if use_bot && turn == 1
                    pile -= bot_turn
                    turn += 1
                else
                    puts "How many sticks are you taking #{$names[turn]}? Choose 1-3."
                    pile -= player_turn
                    turn += 1
                end
            end
        end
        turn = 0
    end

end


def player_turn()
    amount_of_sticks = gets.chomp
    while amount_of_sticks.to_i < 1 || amount_of_sticks.to_i > 3
        if amount_of_sticks != "0" && amount_of_sticks.to_i == 0
            puts "Please send in a whole number between 1-3"
        else
            puts "You tried to take #{amount_of_sticks} sticks. Please choose between 1-3 sticks."
            amount_of_sticks = gets.chomp
        end
    end
    return amount_of_sticks.to_i
end


def bot_turn(c_data)
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
end


def main_loop()

    $game_state = 0
    $names = []

    # starup

    # load game data?
    # skriver ngt
    begin
        while true
            if $game_state == 0
                main_menu()
                $game_state == 1
            end

            if $game_state == 1
                game_loop()
            end

            p "h"


        end

    rescue Interrupt


        # save curent game (if any)
        print("!")

    end
end


main_loop()