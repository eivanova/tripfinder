#!/usr/bin/env ruby

# This implementation of the Eliza chatterbot is inspired by 
# Charles Hayden's Java code at http://www.chayden.net/eliza/Eliza.html

class Script
  attr_accessor :debug_print

  def initialize(source)
    if source.kind_of? IO
      parse source
    else
      File.open(source, 'r') { |f| parse f }
    end
  end

  def repl(is = $stdin, os = $stdout)
    os.puts @initial.sample

    while true
      os.print "> "
      input = is.gets
      break unless input
      input.strip!
      next if input.empty?
      break if @quit.include? input
      os.puts transform(input)
      os.puts @discoveries if @debug_print
    end
    os.puts @discoveries
    os.puts @final.sample    
  end

  def print_script(os = $stdout)
    @initial.each       { |str|      os.puts "initial: #{str}"         }
    @final.each         { |str|      os.puts "final: #{str}"           }
    @quit.each          { |str|      os.puts "quit: #{str}"            }
    @pre.each           { |src,dest| os.puts "pre: #{src} #{dest}"     }
    @post.each          { |src,dest| os.puts "post: #{src} #{dest}"    }
    @synons.values.each { |arr|      os.puts "synon: #{arr.join(' ')}" }
    @keys.values.each   { |key|      key.print(os)                     }
  end

private
  class Key
    attr_reader :name, :rank, :decompositions

    def initialize(name, rank = 1)
      @name = name
      @rank = rank
      @decompositions = []
    end

    def print(os = $stdout)
      os.puts "key: #{@name} #{@rank}"
      @decompositions.each { |d| d.print(os) }
    end
  end

  class Decomp
    attr_reader :mem, :pattern, :reassemblies

    def initialize(mem, pattern)
      @mem = mem
      @pattern = pattern
      @reassemblies = []
      @current = 0
    end

    def next_reasmb
      reasmb = @reassemblies[@current]
      @current = (@current + 1) % @reassemblies.size
      reasmb
    end

    def print(os = $stdout)
      os.puts "  decomp: #{@mem ? '$ ' : ''}#{@pattern}"
      @reassemblies.each { |r| os.puts "    reasmb: #{r}" }
    end
  end

  def parse(f)
    @initial = []
    @final   = []
    @quit    = []
    @pre     = {}
    @post    = {}
    @synons  = {}
    @keys    = {}
    @memory  = []
    @discover = {}
    @discoveries = {}

    for line in f.readlines
      if /^initial: (.*)$/ =~ line
        @initial << $1
      elsif /^final: (.*)$/ =~ line
        @final << $1
      elsif /^quit: (.*)$/ =~ line
        @quit << $1
      elsif /^pre: (\S+) (.*)$/ =~ line
        @pre[$1] = $2
      elsif /^post: (\S+) (.*)$/ =~ line
        @post[$1] = $2
      elsif /^synon: (.*)$/ =~ line
        words = $1.split
        @synons[words[0]] = words
      elsif /^key: (\S+) (\d+)$/ =~ line
        last_key = Key.new($1, $2.to_i)
        @keys[$1] = last_key
      elsif /^key: (\S+)$/ =~ line
        last_key = Key.new($1)
        @keys[$1] = last_key
      elsif /^  decomp: (\$ )?(.+)$/ =~ line
        last_decomp = Decomp.new(!!$1, $2)
        last_key.decompositions << last_decomp
      elsif /^    reasmb: (.+)$/ =~ line
        last_decomp.reassemblies << $1
      elsif /^discover: (.+)$/ =~ line
        last_discover = $1
	@discover[$1] = []
      elsif /^  template: (.*)$/ =~ line
	@discover[last_discover] << $1
      elsif /^hit: (.+)$/ =~ line
        @hit = $1
      end
    end

    check_script
  end

  def check_script()
    for key in @keys.values
      for decomp in key.decompositions
        if /@(\w+)/ =~ decomp.pattern
          raise "Can not find synonyms: #{$1}" unless @synons[$1]
        end
        for reasmb in decomp.reassemblies
          if /^goto (.*)$/ =~ reasmb
            raise "Can not find goto key: #{$1}" unless @keys[$1]
          end
        end
      end
    end
  end

  def replace(str, replacements)
    words = str.split(/[ !?.,-]/)
    words.map! { |word| replacements[word] || word }
    words.join(' ')
  end

  def transform(str)
    str.downcase!

    # convert punctuation to periods
    str.gsub!(/[?!,]/, '.')
    
    # preprocess input string
    str = replace(str, @pre)
    
    hit_happened = false;
    # do each sentence separately
    for sentence in str.split('.')
      $stderr.puts "trying to transform sentence: #{sentence}" if @debug_print
      
     hit_happened = match_discoveries(sentence)

      if reply = transform_sentence(sentence)
        return reply
      end
    end
    
    if hit_happened
      reply = transform_sentence(@hit)
      return reply if reply
    end

    # nothing matched, so try memory
    reply = @memory.shift
    $stderr.puts "memory reply: #{reply} " if @debug_print
    if reply
      return reply
    end

    # no memory, reply with xnone
    if key = @keys['xnone']
      if reply = decompose(key, str)
        return reply if reply.kind_of? String
      end
    end

    "I am at a loss for words."
  end

  def match_discoveries(sentence)
    matched = false
    for key in @discover.keys
      for pattern in @discover[key]
        pattern = expand_regex(pattern)
        regex = Regexp.new(pattern)
	if regex =~ sentence
          # we assume that in each pattern there is a named group referring to the key
          match = regex.match(sentence)[key]
	  @discoveries[key] ? @discoveries[key] << match : @discoveries[key] = [match]
	  matched = true
	end
      end
    end
    matched
  end

  def transform_sentence(str)
    # find keywords sorted by rank in descending order
    keywords =
      str.split
      .map { |word| @keys[word] }
      .compact
      .sort { |a,b| b.rank <=> a.rank }

    for key in keywords
      while key.kind_of? Key
        result = decompose(key, str)
        return result if result.kind_of? String
        key = result
      end
    end

    nil
  end

  # decompose will either return a new key to follow, the reply as a string or nil
  def decompose(key, str)
    $stderr.puts "trying keyword: #{key.name}" if @debug_print

    for d in key.decompositions
      $stderr.puts "trying decomposition: #{d.pattern}" if @debug_print

      # build a regular expression
      regex_str = d.pattern.gsub(/(\s*)\*(\s*)/) do |m|
        s = ''
        s += '\b' if not $1.empty?
        s += '(.*)'
        s += '\b' if not $2.empty?
        s
      end
      # include all synonyms for words starting with @
      regex_str = expand_regex(regex_str)

      $stderr.puts "decomposition regex: #{regex_str}" if @debug_print

      if m = /#{regex_str}/.match(str)
        return assemble(d, m)
      end
    end

    nil
  end

  def expand_regex(regex_str)
    regex_str.gsub!(/@(\w+)/) do |m|
      "(#{@synons[$1].join('|')})"
    end
    regex_str
  end

  def assemble(decomp, match)
    reasmb = decomp.next_reasmb
    $stderr.puts "using reassembly pattern: #{reasmb}" if @debug_print

    if /^goto (.*)$/ =~ reasmb
      return @keys[$1]
    end

    # assemble reply with help of decomposition matches and postprocessing
    reply = reasmb.gsub(/\((\d)\)/) { |m| replace(match[$1.to_i], @post) }
    $stderr.puts "reply after assembly: #{reply}" if @debug_print

    if decomp.mem
      $stderr.puts "save to memory: #{reply}" if @debug_print
      @memory << reply
      $stderr.puts "memory: #{@memory}" if @debug_print
      return reply
    end

    reply
  end
end

# Patch the array class to add a 'sample' method if it doesn't exixts.
# It was added to Ruby in 1.9 and returns a random element.
if not [].respond_to? :sample
  class Array
    def sample
      self[rand(length)]
    end
  end
end

if __FILE__ == $0
  require 'optparse'

  debug_print = false
  script_source = DATA

  OptionParser.new do |opts|
    opts.on("-d", "--debug-print") do |b|
      debug_print = b
    end
    opts.on("-s", "--script PATH") do |path|
      script_source = path
    end
  end.parse!(ARGV)

  script = Script.new(script_source)
  script.debug_print = debug_print
  script.repl
end

__END__
