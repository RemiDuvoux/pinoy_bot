# Showcases a chained sequence of commands that gather the data
# and store it in the answers hash inside the User instance.
module Questionnaire
  # State 'module_function' before any method definitions so
  # commands are mixed into Dispatch classes as private methods.
  module_function

  $points_count = 0
  puts $points_count

  def start_questionnaire
    # get_user_info
    if @message.quick_reply == 'START_QUESTIONNAIRE' || @message.text =~ /yes/i
      say "Great! What's your name?"
      say "(type 'Stop' at any point to exit)"
      next_command :handle_name_and_ask_question_1
    else
      say "No problem! Let's do it later"
      stop_thread
    end
  end

  def handle_name_and_ask_question_1
    # Fallback functionality if stop word used or user input is not text
    fall_back && return
    @user.answers[:name] = @message.text
    say "#{@message.text}, I'm very happy to meet you! Let's get started with the quizz!"
    reply = UI::QuickReplies.build(%w[Buko BUKO], %w[Banana BANANA])
    say "Which one of this fruits is amazing for the immune system?", quick_replies: reply
    next_command :handle_question_1_and_ask_question_2
  end

  def handle_question_1_and_ask_question_2
    fall_back && return
    @user.answers[:question_1] = @message.text
    if @user.answers[:question_1] == "Buko"
      $points_count += 1
      say "Good job!"
    else
      say "Nooooo 😓"
    end
    reply = UI::QuickReplies.build(%w[Pear PEAR], %w[Mango MANGO])
    say "Which one of these fruits and veggies CANNOT be found in the Philippines?", quick_replies: reply
    next_command :handle_question_2_and_ask_question_3
  end

  def handle_question_2_and_ask_question_3
    fall_back && return
    @user.answers[:question_2] = @message.text
    if @user.answers[:question_2] == "Pear"
      $points_count += 1
      say "Good job!"
    else
      say "Nooooo 😓"
    end
    reply = UI::QuickReplies.build(%w[Watermelon WATERMELON], %w[Nut NUT])
    say "Which one of these fruits is full of water?", quick_replies: reply
    next_command :handle_question_3_and_ask_question_4
  end

  def handle_question_3_and_ask_question_4
    fall_back && return
    @user.answers[:question_3] = @message.text
    if @user.answers[:question_3] == "Watermelon"
      $points_count += 1
      say "Good job! 🍉 is full of water: 92 percent exactly. Amazing, right?"
    else
      say "Nooooo 😓"
    end
    reply = UI::QuickReplies.build(%w[Tomato TOMATO], %w[Chili CHILI])
    say "Which one of these fruits will bring you all the vitamin A you need?", quick_replies: reply
    next_command :handle_question_4_and_stop_questionnaire
  end

  def handle_question_4_and_stop_questionnaire
    fall_back && return
    @user.answers[:question_4] = @message.text
    if @user.answers[:question_4] == "Tomato"
      $points_count += 1
      say "Good job!"
    else
      say "Nooooo 😓"
    end
    stop_questionnaire
  end

  def stop_questionnaire
    stop_thread
    show_results
    @user.answers = {}
  end

  def show_results
    name = @user.answers.fetch(:name, 'N/A')
    gender = @user.answers.fetch(:gender, 'N/A')
    age = @user.answers.fetch(:age, 'N/A')
    text = "Name: #{name}, " \
           "points: #{$points_count} out of 4"
    say text
    if $points_count == 4
      say "Wow, you're amazingly knowledgeable about Filipino Fruits and veggies!"
    elsif $points_count == 3 || $points_count == 2
      say "You're good, but can get better!"
    else
      say "You still have a lot to learn about fruits and veggies!"
    end
    say 'Thanks for your time, and talk to you again!'
    $points_count = 0
  end

  # NOTE: A way to enforce sanity checks (repeat for each sequential command)
  def fall_back
    say 'You tried to fool me, human! Start over!' unless text_message?
    return false unless !text_message? || stop_word_used?('Stop')
    stop_questionnaire
    puts 'Fallback triggered!'
    true # to trigger return from the caller on 'and return'
  end

  # specify stop word
  def stop_word_used?(word)
    !(@message.text =~ /#{word.downcase}/i).nil?
  end
end
