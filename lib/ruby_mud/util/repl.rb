# Rudimentary REPL implementation. Supports navigating history of commands with the up/down arrow keys and editing in
# place. Prints objects that respond to `inspect`, or string representation of result value of commands.
class REPL
  def initialize(prompt: 'repl> ')
    require 'io/console'

    @prompt = prompt
    @command_history = ['']
    @command_history_index = 0
    @pending_command = ''
    @cursor_position = 0
  end

  def start
    repl_binding = binding

    # TODO: something in here is causing all future terminal commands in that session to append a newline character.
    # this persists after the server is killed and a new terminal window must be opened
    loop do
      print @prompt

      command = build_console_command

      if command.blank?
        next
      elsif command == 'exit' || command == 'quit'
        puts 'Exiting REPL'
        break
      end

      # catch anything here and just print it back. NOTE: this catches syntax errors too, so anything within `begin`
      # needs to be foolproof
      begin
        evaluated_command = eval(command, repl_binding)
      rescue Exception => e
        puts e.inspect
      end

      if evaluated_command.is_a?(String)
        puts evaluated_command
      elsif evaluated_command.respond_to?(:inspect)
        puts evaluated_command.inspect
      else
        puts evaluated_command
      end
    end
  end

  private

  # Experimental helper functions for reading from the console
  # See: https://gist.github.com/acook/4190379

  # Reads keypresses from the user including 2 and 3 escape character sequences.
  def read_char
    # STDIN.echo = false
    STDIN.raw!

    input = STDIN.getc.chr
    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil
      input << STDIN.read_nonblock(2) rescue nil
    end
  ensure
    # STDIN.echo = true
    STDIN.cooked!

    return input
  end

  def build_console_command
    loop do
      c = read_char
    
      case c
      # ctrl-c
      when "\u0003"
        # reset the pending one
        @pending_command = ''
        @cursor_position = 0

        puts
        return 'exit'
      # when " "
      #   puts "SPACE"
      # when "\t"
      #   puts "TAB"
      when "\r", "\n"
        # reset the pending one and get ready to register/handle this command
        command = @pending_command.dup
        @pending_command = ''
        @cursor_position = 0

        # add the command to history, pulling the last empty string and re-adding it
        # TODO: limit the total number of commands we save?
        @command_history.insert(@command_history.count - 1, command)
        @command_history_index = @command_history.count - 1

        # need to "echo" or insert the newline that was captured here
        puts

        return command
      # when "\e"
      #   puts "ESCAPE"
      # up arrow
      when "\e[A"
        if @command_history_index > 0
          @command_history_index -= 1
        end

        @pending_command = @command_history[@command_history_index].dup
        @cursor_position = @pending_command.length

        print prompt_with_pending_command
      # down arrow
      when "\e[B"
        if @command_history_index < (@command_history.count - 1)
          @command_history_index += 1
        end

        @pending_command = @command_history[@command_history_index].dup
        @cursor_position = @pending_command.length

        print prompt_with_pending_command
      # right arrow
      when "\e[C"
        @cursor_position += 1
        print c
      # left arrow
      when "\e[D"
        @cursor_position -= 1
        print c
      # backspace and macOS delete
      when "\177", "\u007F"
        if @cursor_position > 0
          @pending_command.slice!(@cursor_position - 1)
          @cursor_position -= 1

          print prompt_with_pending_command
        end
      # delete and macOS alternate delete
      when "\004", "\e[3~"
        if @cursor_position < @pending_command.length
          @pending_command.slice!(@cursor_position)

          print prompt_with_pending_command
        end
      # any other ASCII character (shouldn't include control codes?)
      when /^.$/
        @pending_command.insert(@cursor_position, c)
        @cursor_position += 1

        print prompt_with_pending_command
      end
    end
  end

  def prompt_with_pending_command
    "\e[2K\r" + @prompt + @pending_command + "\e[D" * (@pending_command.length - @cursor_position)
  end
end
