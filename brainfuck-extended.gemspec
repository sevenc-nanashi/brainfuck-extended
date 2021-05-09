Gem::Specification.new do |s|
  s.name = "brainfuck-extended"
  s.version = "0.0.2"
  s.summary = "An extended BrainFuck."
  s.description = <<-EOF
  An extended BrainFuck.
  You can use random, you can use 2D data, you can use temp data.
  EOF
  s.authors = ["sevenc-nanashi"]
  s.email = "sevenc-nanashi@sevenbot.jp"
  s.files = ["main.rb"]
  s.homepage =
    "https://github.com/sevenc-nanashi/brainfuck-extended"
  s.license = "MIT"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/sevenc-nanashi/brainfuck-extended/issues",
    "homepage_uri" => "https://github.com/sevenc-nanashi/brainfuck-extended",
    "source_code_uri" => "https://github.com/sevenc-nanashi/brainfuck-extended",
  }
  s.add_runtime_dependency "colorize"
  s.add_runtime_dependency "tty-cursor"
  s.bindir = "bin"
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
end
