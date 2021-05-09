require "io/console"
require 'io/console/size'
require 'timeout'
require "colorize"
require "tty-cursor"
require 'optparse'
opt = OptionParser.new
visible = false
debug = false
opt.on('-v', "--verbose", "Run with verbose mode") { |v|
  visible = v
}
opt.on('-d', "--debug", "Run with debug mode") {|v| 
  debug = v
  if v
    visible = true
  end
}
opt.banner += ' file'
opt.parse!(ARGV)
script = ""
if ARGV[0] == nil
  script = "
  ///++++++++[^^^++++++++///-]^^^:/
  ;///++++++++[^^^++++///-]
  /++++[^^^++++++++///-]^^^^^

  >;++++++.
  </:>;+++++++++.
  +++.
  ;+++++.
  </.

  ^^:>;///++[^^^+++++++///-]^^^.
  /<:>;///+++[^^^+++++///-]^^^.
  :>;<+++++.
  </.

  ^^>+++++.
  /----.
  <:>>;+++++.
  :>;--.
  ++++++.
  <+.
  >.
  <-.
  -.
  <</:>;///+++[^^^++++///-]^^^++.
  "
elsif not File.exists?(ARGV[0])
  script = "
  ///++++++++[^^^++++++++///-]^^^:/
  ;///++++++++[^^^++++///-]
  /++++[^^^++++++++///-]^^^^^
  >;++++++.
  :>;<</:>;+++++++++.
  +++.
  ;+++++.
  </.
  ^^:>;///++[^^^+++++++///-]^^^.
  /<:>;///+++[^^^+++++///-]^^^.
  :>;<+++++.
  </.
  ^^>>.
  /.
  :>;++++++.
  <-.
  <<:>;++++.
  </:>;///+++[^^^++++///-]^^^++.
  "
else
  File.open(ARGV[0], "r") do |f|
    script = f.read
  end
end
cursor = TTY::Cursor
index = 0
cursor_x = 0
cursor_y = 0
field = [[0]]
brackets = []
bracket_pairs = {}
clipboard = 0
output = ""
WIDTH = IO::console_size[1]
script = script.split("").filter{ |c| ".,/^<>[]?+-:;".include?(c)}.join("")
$finish_flag = false
if visible
  print cursor.clear_screen
  puts (" " * WIDTH).on_blue
  print "  ".on_blue
  print "Brainfuck Extended".center(WIDTH - 4)
  puts "  ".on_blue
  puts (" " * WIDTH).on_blue
  puts ""
end
# Lint
lint_brackets = []
script.split("").each_with_index do |c, i|
  case c
  when "["
    lint_brackets << i
  when "]"
    n = lint_brackets.delete_at(-1)
    if n == nil
      raise "SyntaxError: Unmatched brackets"
    else
      bracket_pairs[n] = i
    end
  end
end
# Execute
until index >= script.length
  current_chr = script[index]
  case current_chr
  when "+"
    field[cursor_y][cursor_x] += 1
  when "-"
    field[cursor_y][cursor_x] -= 1
  when ">"
    cursor_x += 1
    if field[cursor_y].length <= cursor_x
      field.each do |f|
        f << 0
      end
    end
  when "<"
    cursor_x -= 1
  when "."
    if visible
      output += field[cursor_y][cursor_x].chr
    else
      $stdout.print field[cursor_y][cursor_x].chr
    end
  when ","
    field[cursor_y][cursor_x] = $stdin.getch
  when "["
    if field[cursor_y][cursor_x] != 0
      brackets << index
    else
      until script[index] == "]"
        index += 1
      end
    end
  when "]"
    if field[cursor_y][cursor_x] == 0
      brackets.delete_at(0)
    else
      index = brackets[-1]
    end
  when "?"
    field[cursor_y][cursor_x] = rand(0..255)
  when ":"
    clipboard = field[cursor_y][cursor_x]
  when ";"
    field[cursor_y][cursor_x] = clipboard
  when "/"
    cursor_y += 1
    if field.length <= cursor_y
      field << Array.new(field[0].length) { 0 }
    end
  when "^"
    cursor_y -= 1
  end
  if cursor_x < 0
    raise "Out of X range: #{cursor_x}"
  end
  if cursor_y < 0
    raise "Out of Y range: #{cursor_y}"
  end
  unless (0..255).include? field[cursor_y][cursor_x]
    raise "Overflow: #{cursor_x}, #{cursor_y}"
  end
  if visible
    sleep(debug ? 0.1 : 0.01)
    print cursor.move_to 0, 4
    print "  ".on_light_blue
    print " Source "
    puts (" " * (WIDTH - 8 - 2)).on_light_blue
    print cursor.clear_line
    running_bracket_ends = []
    primary_bracket_end = -1
    script.split("").each_with_index do |c, i|
      if script.length <= WIDTH
        do_print = true
      elsif index < WIDTH / 2
        do_print = i < WIDTH
      elsif index >= script.length - WIDTH / 2
        do_print = i > script.length - WIDTH
      else
        do_print = [(index - i).abs, 0].max < WIDTH / 2
      end
      if brackets[-1] == i
        primary_bracket_end = bracket_pairs[i]
        print c.light_green  if do_print
      elsif primary_bracket_end == i
        print c.light_green  if do_print
      elsif brackets.include?(i)
        running_bracket_ends << bracket_pairs[i]
        print c.green  if do_print
      elsif index == i
        print c.yellow  if do_print
      elsif running_bracket_ends.include?(i)
        print c.green  if do_print
      else
        print c  if do_print
      end
    end
    puts 
    print "  ".on_light_blue
    print " Output "
    puts (" " * (WIDTH - 8 - 2)).on_light_blue
    puts output
    pos_txt = "#{clipboard}   #{cursor_x}, #{cursor_y}"
    print "  ".on_light_blue
    print " Field "
    print (" " * (WIDTH - 7 - 2 - pos_txt.length - 2)).on_light_blue
    print pos_txt.on_light_blue.light_white
    puts "  ".on_light_blue
    max_length = field.flatten.map { |i| i.to_s.length }.max
    print cursor.clear_line
    print "  "
    field[0].length.times do |i|
      print i.to_s.rjust(max_length).colorize(i == cursor_x ? :light_blue : :blue)
      print " "
    end
    print "\n"
    field.each_with_index do |f, j|
      print cursor.clear_line
      print j.to_s.colorize(j == cursor_y ? :light_blue : :blue)
      print " "
      f.each_with_index do |v, i|
        
        res = v.to_s.rjust(max_length)
        case [i,j]
        in [^cursor_x, ^cursor_y]
          print res.light_green
        in [^cursor_x, _] | [_, ^cursor_y]
          print res.green
        else
          print res
        end
        print " "        
      end

      print "\n"
    end
  end
  index += 1
end
if visible
  print "Waiting for input..."
  $stdin.getch
end
