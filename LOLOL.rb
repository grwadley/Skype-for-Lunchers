#!/usr/bin/env ruby
require 'rubygems'
$:.unshift File.expand_path '../lib', File.dirname(__FILE__)
require 'skype'

def lolol(chat,body,user)
  message = "[Skype Bot]  "
  message += ((user.to_s)+" said: \" "+(body.to_s)+"\""+"\n HAHAHAHAHA")
  chat.post message
end

###
#Runtime and Setup.
#establish a launch time, and connect to skype
###
runTime = Time.new
puts runTime

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
        unless(m.body=~/^\[Skype Bot\]/)
          lolol(chat,m.body,m.user)
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