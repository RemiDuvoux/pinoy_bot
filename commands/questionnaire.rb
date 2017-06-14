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
    if @message.quick_reply == 'QUESTIONNAIRE' || @message.text =~ /yes/i
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
    sleep(0.5)
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
    reply = UI::QuickReplies.build(%w[Kalamansi KALAMANSI], %w[Mango MANGO])
    sleep(0.5)
    say "Which fruit has got the most vitamin C?", quick_replies: reply
    next_command :handle_question_2_and_ask_question_3
  end

  def handle_question_2_and_ask_question_3
    fall_back && return
    @user.answers[:question_2] = @message.text
    if @user.answers[:question_2] == "Kalamansi"
      $points_count += 1
      say "Good job!"
    else
      say "Nooooo 😓"
    end
    reply = UI::QuickReplies.build(%w[Watermelon WATERMELON], %w[Apple APPLE])
    sleep(0.5)
    say "Which one of these fruits is made of 92 percent of water?", quick_replies: reply
    next_command :handle_question_3_and_ask_question_4
  end

  def handle_question_3_and_ask_question_4
    fall_back && return
    @user.answers[:question_3] = @message.text
    if @user.answers[:question_3] == "Watermelon"
      $points_count += 1
      say "Good job!"
    else
      say "Nooooo 😓"
    end
    reply = UI::QuickReplies.build(%w[Tomato TOMATO], %w[Chili CHILI])
    sleep(0.5)
    say "Which one of these fruits will bring you all the vitamin A you need?", quick_replies: reply
    next_command :handle_question_4_and_ask_question_5
  end

  def handle_question_4_and_ask_question_5
    fall_back && return
    @user.answers[:question_4] = @message.text
    if @user.answers[:question_4] == "Tomato"
      $points_count += 1
      say "Good job!"
    else
      say "Nooooo 😓"
    end
    reply = UI::QuickReplies.build(['An enzym: Bromelain','BROMELAIN'], ['Melanin','MELANIN'])
    sleep(0.5)
    say "Why does the Pineapple make your tongue feel like sand paper?", quick_replies: reply
    next_command :handle_question_5_and_ask_question_6
  end

  def handle_question_5_and_ask_question_6
    fall_back && return
    @user.answers[:question_5] = @message.text
    if @user.answers[:question_5] == "An enzym called Bromelain"
      $points_count += 1
      say "Good job!"
    else
      say "Nooooo 😓"
    end
    say "Pineapple cores contain high levels of bromelain, a proteolytic enzyme that breaks down proteins. That's why pineapple can even be used as a meat tenderizer!"
    reply = UI::QuickReplies.build(['From trees','TREES'], ['From the ground','GROUND'])
    sleep(0.5)
    say "How do pineapples grow?", quick_replies: reply
    next_command :handle_question_6_and_ask_question_7
  end

  def handle_question_6_and_ask_question_7
    fall_back && return
    @user.answers[:question_6] = @message.text
    if @user.answers[:question_6] == "They grow from the ground"
      $points_count += 1
      say "Good job!"
    else
      say "Nooooo 😓"
    end
    say "Pineapples grow from the ground up!"
    reply = UI::QuickReplies.build(['Cactus','CACTUS'], ['Palm tree','PALM TREE'])
    sleep(0.5)
    say "On which kind of tree do the dragon fruits grow?", quick_replies: reply
    next_command :handle_question_7_and_stop_questionnaire
  end

  def handle_question_7_and_stop_questionnaire
    fall_back && return
    @user.answers[:question_7] = @message.text
    if @user.answers[:question_7] == "Cactus"
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
    text = "Name: #{name}, " \
           "points: #{$points_count} out of 7"
    say text
    if $points_count == 7
      say "Wow, you're amazingly knowledgeable about Filipino Fruits! You will love www.plushandplay.com for sure!"
    elsif $points_count < 7 && $points_count > 0
      say "You're good, but can get better! Maybe you should visit plushandplay.com"
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
