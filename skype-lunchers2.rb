#!/usr/bin/env ruby
require 'rubygems'
$:.unshift File.expand_path '../lib', File.dirname(__FILE__)
require 'skype'
###
#Definitions
###


#Pokebattle. Select two random teams for two users and choose a winner based off of
# team base stat totals
def pokebattle(chat,body,user)
  lines = IO.readlines("pokemonStats")
  team1 = []
  team2 = []
  temp = ""

  pokes = 0
  select = 0
  #fill team arrays using incredibly ugly regexcham
  until pokes>5
    select = (rand()*lines.length).to_i
    temp = lines[select].match /([a-zA-Z])(r\.\s\w*|\w*-\w*|.*\(.*\)|\w*)(\s*)(\d*)(\s*)(\d*)(\s*)(\d*)(\s*)(\d*)(\s*)(\d*)(\s*)(\d*)(\s*)(\d*)/
    team1 << [($1.to_s+$2.to_s),$16.to_i]
    lines.delete_at(select)

    select = (rand()*lines.length).to_i
    temp = lines[select].match /([a-zA-Z])(r\.\s\w*|\w*-\w*|.*\(.*\)|\w*)(\s*)(\d*)(\s*)(\d*)(\s*)(\d*)(\s*)(\d*)(\s*)(\d*)(\s*)(\d*)(\s*)(\d*)/
    team2 << [($1.to_s+$2.to_s),$16.to_i]
    lines.delete_at(select)
    pokes+=1
  end
  #Create the initial messages by looping through teams and extractin from user and body of the message
  #We go ahead and sum the score while we're iterating through the teams
  sum1 = 0
  sum2 = 0
  temp = user.match /(\w*)./
  player1 = $1.to_s
  messageP1 = "[Skype Bot]  ["+player1+"'s team: ]"
  team1.each do |pokemon|
    messageP1 += " "+pokemon[0].to_s
    sum1 += pokemon[1].to_i
  end

  temp = body.match /(\w*)(\s)(\w*)/
  player2 = $3.to_s
  messageP2= "["+player2+"'s team: ]"
  team2.each do |pokemon|
    messageP2 += " "+pokemon[0].to_s
    sum2 += pokemon[1].to_i
  end

  #Post the results
  chat.post messageP1+ " [Total: "+ sum1.to_s+"]"
  chat.post messageP2+ " [Total: "+ sum2.to_s+"]"
  if sum1>sum2
    chat.post player1+" wins!"
  elsif sum1 == sum2
    chat.post "Draw!"
  else
    chat.post player2+" wins!"
    #if(player2=~/^lorelei$/i)
     # chat.post "http://i.imgflip.com/4tjpx.jpg"
    #end
  end
end

#Generates a random deck of dominion cards from a local textfile. This one has some complicated regex because the formats are all strange
#Regex is used to pull the necessary values from each line.
def dominion(chat)  board = []
  cardCost = "";
  cards = 0;
  select = 0;
  line = "[Skype Bot]  ";
  temp="";

  lines_array = IO.readlines("dominionCards")
  until cards > 9 do
    cards+=1
    select = (rand() * lines_array.length).to_i
    temp = lines_array[select].match /(^\w.*?)(\s)(\$\d+)/
    board << [$1,$3]
    lines_array.delete_at(select)
  end

  board = board.sort{|a,b| b[1] <=>a[1]}
  #Add special symbols
  board.each do |card|
    card[0]= card[0].sub(/\W*/,"")
    card[0]= card[0].sub(/\s–\s/,"")
    card[0]= card[0].sub(/Action/,"(→) ")
    card[0]= card[0].sub(/Attack/,"(⚔) ")
    card[0]= card[0].sub(/Treasure/,"( $) ")
    card[0]= card[0].sub(/Victory/,"(♕) ")
    card[0]= card[0].sub(/Duration/,"(∞) ")
    card[0]= card[0].sub(/Reaction/,"(⟲) ")
  end


  board.each do |card|
    if(card[1]==cardCost)
      line+="["+card[0].to_s+"]"
    else
      line+= "\n"+"["+card[1].to_s+"]["+card[0].to_s+"]"
      cardCost = card[1]
    end
    line+="\t"
  end
  dominionKingdom = board
  chat.post line
end

def dominionLinks(chat)
  puts 'here'
  dominionKingdom.each do |card|
    puts card
  end
end

def dominionLink(chat,body)
  temp = body.match /(dominion)(\s)(\w*)/
  card = $3
  message = "http://wiki.dominionstrategy.com/index.php/"+card.downcase
  chat.post message
end

#Simple die roll function. Takes the username from the message to tell who rolled
def roll(chat,user)
  num = ((rand()*6).to_i + 1)
  message = "[Skype Bot]  "
  message += user.to_s
  message += " rolled "+num.to_s
  chat.post message
end

#To remember David's finest moment
def lux(chat)
  chat.post "[Skype Bot]  FLASH FOR FIRSTBLOOD!"
end

#Prints the dominion scoreboard. This is currently stored locally in a text file.
#sort is only on wins. A star is printed beside the names of the leader(s)
def scoreboard(chat)
   scores = []
  lines = IO.readlines("scoreboard")
  winners = IO.readlines("winners")
  message = "[Skype Bot]  [Winners] "
  winners.each do |line|
    message+="["+line+"] "
  end
  message+="\n[Current Scores] "
  temp = ""
  max = 0
  lines.each do |line|
    temp = line.match /(.*:)(\s)(-\d*|\d*)/
    if $3.to_i > max
      max = $3.to_i
    end
    scores << [$1,$3.to_i]
  end
  scores = scores.sort{|a,b| b[1] <=>a[1]}
  scores.each do |line|
    if line[1] == max
      message += ("[ (*) "+line[0]+" "+line[1].to_s+"]")
    else
      message += ("["+line[0]+" "+line[1].to_s+"]")
    end
  end
  chat.post message
end
#generates a team of six pokemon from a local textfile. Regex is complicated by wierd names like Ho-oH
# and Mr. Mime. Pokemon are removed with each step to prevent duplicates
def pokemon(chat)
  select = 0
  temp = ""
  lines = IO.readlines("pokemon")
  message = "[Skype Bot]  [Your random pokemon team:]"
  team = 0
  until team >5
    select = (rand() * lines.length).to_i
    temp = lines[select].match /(\d{3})(\s)(Mr.\s\w*|\w*-\w*|\w*)/
    message +=("["+$1+" "+$3+"]")
    lines.delete_at(select)
    team+=1
  end
  chat.post message
end

#same functionality as before but has an upper limit. Duplicates are now allowed
def pokemonLimit(chat,body)
  select = 0
  temp = ""
  lines = IO.readlines("pokemon")
  message = "[Skype Bot]  [Your random pokemon team:]"
  team = 0
  #regex matching is used to pull the number from the message body
  temp = body.match /(\w*)(\s)(\d*)/
  max = $3.to_i
  if max > lines.length
    message = "[Skype Bot]  [Number too large]"
  else
    until team >5
      select = (rand() * max).to_i
      temp = lines[select].match /(\d{3})(\s)(Mr.\s\w*|\w*-\w*|\w*)/
      message +=("["+$1+" "+$3+"]")
      team+=1
    end
  end
  chat.post message
end

def champions(chat)
  message = "[Skype Bot]  Trainers who have defeated the Elite Four and Champion: \n"
  lines = IO.readlines("champions")
  lines.each do |name|
    message+= "[ (*) "+name.to_s.strip+"]\n"
  end
  chat.post message
end

def gary(chat)
  message = "[Skype Bot] Gary Wins! Smell Ya Later!"
  chat.post message
end

#print the possible commands
def commands(chat)
  chat.post "[Skype Bot]  Commands: dominion, lux, scoreboard, pokemon (optional #), roll, pokebattle (opponent), champions"
end

###
#Runtime and Setup.
#establish a launch time, and connect to skype
###
runTime = Time.new
puts runTime

dominionKingdom  = []

puts "skype rubygem v#{Skype::VERSION}"

chats = Skype.chats
puts "#{chats.length} chats found"
chats.each_with_index do |c, index|
  title = "#{c.topic} #{c.members[0..5].join(',')} (#{c.members.size} users)".strip
  puts "[#{index}] #{title}"
end

###
#Choose the chat on which to run the bot
###
chat = nil
loop do
  print "select [0]~[#{chats.size-1}] >"
  line = STDIN.gets.strip
  next unless line =~ /^\d+$/
  chat = chats[line.to_i]
  break
end


###
#Continuously loop to find new messages. Each message is checked with a timestamp to ensure
#we aren't looking at old messages
#Use regex to look for user commands, ensuring that they are the start and end of the line
#chat must be passed to all functions to allow them to post successfully. Message ID, Body, Time, and User can also be passed
###
Thread.new do
  last_id = 0
  loop do
    chat.messages.each do |m|
      if m.time > runTime
        next unless last_id < m.id
        puts m
        if(m.body=~/^help$/i)
          commands(chat)
        elsif(m.body=~/^roll$/i)
          roll(chat,m.user)
        elsif(m.body=~/^champions$/i)
          champions(chat)
        elsif(m.body=~/^pokebattle \w*$/i)
          pokebattle(chat,m.body,m.user)
        elsif(m.body=~/^dominion$/i)
          dominion(chat)
        elsif(m.body=~/^dominion links$/)
          dominionLinks(chat)
        elsif(m.body=~/^dominion \w*$/i)
          dominionLink(chat,m.body)
        elsif(m.body=~/^lux$/i)
          lux(chat)
        elsif(m.body=~/^scoreboard$/i)
          scoreboard(chat)
        elsif(m.body=~/^pokemon$/i)
          pokemon(chat)
        elsif(m.body=~/^pokemon \d*$/i)
          pokemonLimit(chat, m.body)
        end
        last_id = m.id
      end
    end
    sleep 1
  end
end

###
#Allows you to post to the chat through the terminal
###
loop do
  line = STDIN.gets.strip
  next if line.empty?
  chat.post line
end