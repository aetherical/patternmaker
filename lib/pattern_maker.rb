#load "ini.rb"
require 'active_support/core_ext/integer'
require 'chunky_png'


#
# ini.rb - read and write ini files
#
# Copyright (C) 2007 Jeena Paradies
# License: GPL
# Author: Jeena Paradies (info@jeenaparadies.net)
#
# == Overview
#
# This file provides a read-wite handling for ini files.
# The data of a ini file is represented by a object which
# is populated with strings.

class Ini
  
  # Class with methods to read from and write into ini files.
  #
  # A ini file is a text file in a specific format,
  # it may include several fields which are sparated by
  # field headlines which are enclosured by "[]".
  # Each field may include several key-value pairs.
  #
  # Each key-value pair is represented by one line and
  # the value is sparated from the key by a "=".
  #
  # == Examples
  #
  # === Example ini file
  #
  #   # this is the first comment which will be saved in the comment attribute
  #   mail=info@example.com
  #   domain=example.com # this is a comment which will not be saved
  #   [database]
  #   db=example
  #   user=john
  #   passwd=very-secure
  #   host=localhost
  #   # this is another comment
  #   [filepaths]
  #   tmp=/tmp/example
  #   lib=/home/john/projects/example/lib
  #   htdocs=/home/john/projects/example/htdocs
  #   [ texts ]
  #   wellcome=Wellcome on my new website!
  #   Website description = This is only a example. # and another comment
  #
  # === Example object
  #
  #   A Ini#comment stores:
  #   "this is the first comment which will be saved in the comment attribute"
  #
  #   A Ini object stores:
  #
  #   {
  #    "mail" => "info@example.com",
  #    "domain" => "example.com",
  #    "database" => {
  #     "db" => "example",
  #     "user" => "john",
  #     "passwd" => "very-secure",
  #     "host" => "localhost"
  #    },
  #    "filepaths" => {
  #     "tmp" => "/tmp/example",
  #     "lib" => "/home/john/projects/example/lib",
  #     "htdocs" => "/home/john/projects/example/htdocs"
  #    }
  #    "texts" => {
  #     "wellcome" => "Wellcome on my new website!",
  #     "Website description" => "This is only a example."
  #    }
  #   }
  #
  # As you can see this module gets rid of all comments, linebreaks
  # and unnecessary spaces at the beginning and the end of each
  # field headline, key or value.
  #
  # === Using the object
  #
  # Using the object is stright forward:
  #
  #   ini = Ini.new("path/settings.ini")
  #   ini["mail"] = "info@example.com"
  #   ini["filepaths"] = { "tmp" => "/tmp/example" }
  #   ini.comment = "This is\na comment"
  #   puts ini["filepaths"]["tmp"]
  #   # => /tmp/example
  #   ini.write()
  # 
  
  #
  # :inihash is a hash which holds all ini data
  # :comment is a string which holds the comments on the top of the file
  #
  attr_accessor :inihash, :comment

  #
  # Creating a new Ini object
  #
  # +path+ is a path to the ini file
  # +load+ if nil restores the data if possible
  #        if true restores the data, if not possible raises an error
  #        if false does not resotre the data
  #
  def initialize(path, load=nil)
    @path = path
    @inihash = {}
    
    if load or ( load.nil? and FileTest.readable_real? @path )
      restore()
    end
  end
  
  #
  # Retrive the ini data for the key +key+
  #
  def [](key)
    @inihash[key]
  end
  
  #
  # Set the ini data for the key +key+
  #
  def []=(key, value)
    raise TypeError, "String expected" unless key.is_a? String
    raise TypeError, "String or Hash expected" unless value.is_a? String or value.is_a? Hash
    
    @inihash[key] = value
  end
  
  #
  # Restores the data from file into the object
  #
  def restore()
    @inihash = Ini.read_from_file(@path)
    @comment = Ini.read_comment_from_file(@path)
  end
  
  #
  # Store data from the object in the file
  #
  def update()
    Ini.write_to_file(@path, @inihash, @comment)
  end

  #
  # Reading data from file
  #
  # +path+ is a path to the ini file
  #
  # returns a hash which represents the data from the file
  #
  def Ini.read_from_file(path)
        
    inihash = {}
    headline = nil
    
    IO.foreach(path) do |line|

      line = line.strip.split(/#/)[0]
      
      # read it only if the line doesn't begin with a "=" and is long enough
      unless line.length < 2 and line[0,1] == "="
        
        # it's a headline if the line begins with a "[" and ends with a "]"
        if line[0,1] == "[" and line[line.length - 1, line.length] == "]"
          
          # get rid of the [] and unnecessary spaces
          headline = line[1, line.length - 2 ].strip
          inihash[headline] = {}
        else
        
          key, value = line.split(/=/, 2)
          
          key = key.strip unless key.nil?
          value = value.strip unless value.nil?
          
          unless headline.nil?
            inihash[headline][key] = value
          else
            inihash[key] = value unless key.nil?
          end
        end        
      end
    end
    
    inihash
  end
  
  #
  # Reading comments from file
  #
  # +path+ is a path to the ini file
  #
  # Returns a string with comments from the beginning of the
  # ini file.
  #
  def Ini.read_comment_from_file(path)
    comment = ""
    
    IO.foreach(path) do |line|
      line.strip!
      break unless line[0,1] == "#" or line == ""
      
      comment << "#{line[1, line.length ].strip}\n"
    end
    
    comment
  end
  
  #
  # Writing a ini hash into a file
  #
  # +path+ is a path to the ini file
  # +inihash+ is a hash representing the ini File. Default is a empty hash.
  # +comment+ is a string with comments which appear on the
  #           top of the file. Each line will get a "#" before.
  #           Default is no comment.
  #
  def Ini.write_to_file(path, inihash={}, comment=nil)
    raise TypeError, "String expected" unless comment.is_a? String or comment.nil?
    
    raise TypeError, "Hash expected" unless inihash.is_a? Hash
    File.open(path, "w") { |file|
      
      unless comment.nil?
        comment.each do |line|
          file << "# #{line}"
        end
      end
      
      file << Ini.to_s(inihash)
    }
  end
  
  #
  # Turn a hash (up to 2 levels deepness) into a ini string
  #
  # +inihash+ is a hash representing the ini File. Default is a empty hash.
  #
  # Returns a string in the ini file format.
  #
  def Ini.to_s(inihash={})
    str = ""
    
    inihash.each do |key, value|

      if value.is_a? Hash
        str << "[#{key.to_s}]\n"
        
        value.each do |under_key, under_value|
          str << "#{under_key.to_s}=#{under_value.to_s unless under_value.nil?}\n"
        end

      else
        str << "#{key.to_s}=#{value.to_s unless value2.nil?}\n"
      end
    end
    
    str
  end
  
end



class PatternMaker
  @@template = {
    "WIF"=>
    {"Version"=>"1.1",
      "Date"=>"April 20, 1997",
      "Developers"=>"matt@woven-threads.net",
      "Source Program"=>"pattern_maker",
      "Source Version" =>"crunchy bacon"
    },
    "CONTENTS"=>
    {"COLOR PALETTE"=>"yes",
      "WEAVING"=>"yes",
      "WARP"=>"yes",
      "WEFT"=>"yes",
      "TIEUP"=>"yes",
      "COLOR TABLE"=>"yes",
      "THREADING"=>"yes",
      "WARP COLORS"=>"yes",
      "TREADLING"=>"yes",
      "WEFT COLORS"=>"yes"},
    "COLOR PALETTE"=>{"Entries"=>"2", "Range"=>"0,255"},
    "WEAVING"=>{"Shafts"=>"2", "Treadles"=>"2", "Rising Shed"=>"no"},
    "WARP"=>
    {"Threads"=>"50",
      "Units"=>"Inches",
      "Spacing"=>"0.08333333",
      "Thickness"=>"0.08333334"},
    "WEFT"=>
    {"Threads"=>"50",
      "Units"=>"Inches",
      "Spacing"=>"0.08333333",
      "Thickness"=>"0.08333334"},
    "TIEUP"=>{"1"=>"1", "2"=>"2"},
    "COLOR TABLE"=>{"1"=>"0,0,128", "2"=>"0,0,0"},
    "THREADING"=>
    {},
    "WARP COLORS"=>
    {},
    "TREADLING"=>
    {},
    "WEFT COLORS"=>
    {}
  }

  def PatternMaker.make_plain_pattern(opts = {})
    options = {
      :colors => {"1"=>"0,0,128", "2"=>"0,0,0"}
    }.merge opts
    self.new(options).make
  end

  def PatternMaker.make_tartan(opts = {})
    options = {
      :pattern => [1,2]
    }.merge opts
    a = options[:pattern]
    if options[:alt]
       options[:pattern] = (a << a.reverse[1..-1]).flatten
    else
      options[:pattern] = (a << a.reverse[1..-2]).flatten
    end
    self.make_plain_pattern(options)
  end

  
  def initialize(opts = {})
    @options = {
      :reverse => false,
      :harnesses => 2,
      :pattern => [1],
      :size => -1,
      :max_size => 50,
      :grid_size => 9,
      :colors => {"1"=>"255,255,255", "2"=>"0,0,0"},
      :dir => "."
    }.merge opts
    @data = Marshal.load(Marshal.dump(@@template))
  end

  def make
    calc_size 
    setup_colors
    make_pattern_space
    populate_threads
    populate_colors
    populate_notes
    populate_text
    write_wif
    self
  end
  
  def setup_colors
    @data["COLOR TABLE"] = @options[:colors]
    @data["COLOR PALETTE"]["Entries"] = @options[:colors].size
  end

  def PatternMaker.make_combos(n=2,opts={})
    a = (1 .. n).to_a
    (2 .. a.size).each do |n|
      a.combination(n) do |x|
        [true,false].each do |flag|
          if (opts[:tartan])
            self.make_tartan(opts.clone.merge({:pattern => x.clone,:reverse => flag})) 
          else
            self.make_plain_pattern(opts.clone.merge({:pattern => x,:reverse => flag}))
            end
        end
      end
    end
  end
  
  def write_description
    
  end
  
  def write_wif
    file_name = make_name
    file_name << ".wif"
    Ini.write_to_file(make_path(file_name),@data)
  end
  
  def make_path(name)
    #Dir.mkdir(@options[:dir]) unless Dir.exist?(@options[:dir])
    "#{@options[:dir]}/#{name}"
  end
  
  def make_name
    file_name = "#{@options[:pattern].join("-")}"
    file_name << "-#{@options[:nickname]}" if @options[:nickname]
    file_name << "-reversed" if @options[:reverse]
    file_name
  end
  
  def calc_size
    if (@options[:size] == -1)
      trial_size = @options[:pattern].inject {|s,v| s+v}
      @options[:size] = trial_size
      @options[:size] += trial_size while @options[:size] < @options[:max_size]
      @options[:size] -= trial_size if (@options[:size] > @options[:max_size])
    end
    @data["WARP"]["Threads"] = @options[:size]
    @data["WEFT"]["Threads"] = @options[:size]
  end
  
  def make_pattern_space()
    @mapping = @options[:pattern].each_with_index.inject([]) do |sum,(size,index)|
#      sum << Array.new(size).map {|z| (index % @options[:harnesses])+1 } 
       sum << Array.new(size).map {|z| (index % @options[:colors].keys.size)+1 }  
    end.flatten
    @pattern_space = Array.new(@options[:size]).each_with_index.map do |x,i|
      @mapping[i % @mapping.size]
    end
  end

  def populate_threads
    (1 .. @options[:size]).each do |n|
      @data["THREADING"][n.to_s] = (n % @options[:harnesses])+1
      @data["TREADLING"][n.to_s] = (n % @options[:harnesses])+1
    end
  end

  def populate_colors
    colors = @data["COLOR TABLE"].keys.sort
    @data["WARP COLORS"] = color_map(colors)

    colors.reverse! if @options[:reverse]
    @data["WEFT COLORS"] = color_map(colors)
  end

  def color_map(colors)
    puts "colors = #{colors.inspect}"
    (1 .. @options[:size]).inject({}) do |s,v|
      #      s.merge({v.to_s => colors[(v - 1) % colors.size]})
      s.merge({v.to_s => colors[@pattern_space[v-1]-1]})
    end
  end

  def populate_notes
    @data["CONTENTS"]["NOTES"]="yes"

    notes = @options[:notes] || <<EOF
This plainweave pattern is formed from a repeating pattern of colored threads.
The pattern is formed as follows:
#{@mapping.each_with_index.map{|n,i| "  #{(i+1).ordinalize} is the #{n.ordinalize} color."}.join("\n")}

This pattern repeats in the warp.
This pattern #{@options[:reverse] ? "is reversed" : "repeats"} in the weft.

#{@options[:nickname] ? "It is also known as #{@options[:nickname]}" :""}

This pattern was created by pattern_maker which was written by
Matthew Williams <matt@woven-threads.net> for
Plain Weave Color Study (http://leanpub.com/ops4devs/plainweave)

The source code may be found at http://github.com/aetherical/pattern_maker

EOF

    @data["NOTES"] = notes.split("\n").each_with_index.inject({}) do |s, (line,num)|
      s.merge({(num + 1).to_s => line})
    end
  end

    def populate_text
      @data["CONTENTS"]["TEXT"]="yes"

      @data["TEXT"] = @options[:notes] || {
        "Title" => "Plainweave #{@options[:pattern].join("-")}#{" (#{@options[:nick_name]})" if @options[:nickname]}#{" Reversed" if @options[:reverse]}".strip,
        "Author" => "Matt Williams",
        "EMail" => "matt@woven-threads.net"
      }
    end

    def coords(x,y)
      [offset(x),offset(y),offset(x)+11,offset(y)+11]
    end
    
    def offset(n)
      (n - 1) * @options[:grid_size]
    end

    def raised?(harness,treadles)
      [treadles].flatten.include? harness
    end

    def decide_color(thread, shot)
      treadles =
        eval("[#{@data["TIEUP"][@data["TREADLING"][shot].to_s]}]")

      color = (raised?(@data["THREADING"][thread.to_s],treadles) ? @data["COLOR TABLE"][@data["WARP COLORS"][thread.to_s]] : @data["COLOR TABLE"][@data["WEFT COLORS"][shot]])
      (r,g,b) = eval("[#{color}]")
      ChunkyPNG::Color.rgb(r,g,b)
    end

    def image_size
	size = @options[:size] * @options[:grid_size]
    end
    
    def make_png
      phys_chunk = Marshal.load("\x04\bo:\x1EChunkyPNG::Chunk::Generic\a:\n@type\"\tpHYs:\r@content\"\x0E\x00\x00.#\x00\x00.#\x01")
	size = image_size
      png = ChunkyPNG::Image.new(size,size, ChunkyPNG::Color::TRANSPARENT)
      @data["TREADLING"].each_pair do |weft_thread, weft_harness|
        @data["THREADING"].each_pair do |warp_thread, warp_harness|
          thread = warp_thread.to_i
          shot = weft_thread.to_i
          (x1,y1,x2,y2) = coords(thread, shot)
          color = decide_color(thread,weft_thread)
          png.rect(x1,y1,x2,y2,color,color)
        end
      end
      png.flip!.mirror!
      ds = png.to_datastream
      ds.other_chunks << phys_chunk
      file_name = make_name
      file_name << ".png"
      ds.save(make_path(file_name))
      self
    end

    
end
