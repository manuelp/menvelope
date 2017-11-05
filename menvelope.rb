require_relative 'lib/envelope'
require 'readline'
require 'abbrev'

ABBREV = %w{ help exit version ls new }.abbrev

Readline.completion_proc = proc do |string|
  ABBREV[string]
end

class Prompt
  def initialize
    @envelopes = []
    @version = "0.1"
    @envelope = nil
  end

  def help_message
    puts """[TODO]"""
  end

  def main_loop
    loop do
      cmd = Readline.readline("menvelope #{@version}# ", true)

      break if cmd.nil?

      tokens = cmd.strip.split(" ")
      
      case tokens[0]
      when "help"
        help_message()
        
      when "version"
        puts "menvelope #{@version}"
        
      when "quit"
        break

      when "exit"
        break
        
      when "new"
        name = tokens[1]
        if !name.nil? and name != "" then
          if @envelope == nil then
            @envelopes << Envelope.new(name)
          else
            @envelope.add_envelope(name)
          end
        else
          puts "An envelope must have a non-empty name!"
        end
        
      when "ls"
        if @envelope.nil? then
          puts "ROOT"
          @envelopes.each {|e| puts e.to_s}
        else
          puts @envelope if !@envelope.nil?
        end

      when "cd"
        name = tokens[1]
        if name.nil? then
          puts "What?!"
        else
          if name == ".." && !@envelope.nil? then
            @envelope = @envelope.parent
          elsif name != ".." then
            known = false
            @envelopes.each do |e|
              if e.name == name then
                known = true
                @envelope = e
              end
            end
            if known != true then
              puts "Unknown envelope!"
            end
          end
        end
      else
        puts "Unknown command, try with \"help\""
      end
    end
  end
end

p = Prompt.new
p.main_loop
