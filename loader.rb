=begin
	Bot13 Loader for Weechat
	version 1.0
=end

$home = Dir.chdir{|path| path}
$repo = "https://github.com/unn4m3d/bot13.git"
$origin = "master"
$version = "1.7.2 Beta"

class ConfList
	attr_accessor:list
	def initialize(h = {})
		@list = h
	end
	def self.load(file)
		f = File.open(file)
		fr = f.readlines
		f.close
		c = ConfList.new({})
		for l in fr
			k = l.sub(/^([^>]+)>.*$/){$1}
			v = l[k.length..-1]
			c.list[k] = v
		end
		return c
	end
	def save(file)
		f = File.open(file,"w")
		for k in @list.keys
			if f.class == "String"
				f.write("#{k}>#{@list[k]}\n")
			elsif f.class == "Array"
				
			elsif f.class == "Hash"
				
			end
		end	
		f.close
	end
end

def weechat_init
	if not Dir.exists?($home + "/bot13/")
		system("git clone #{$repo}")
	end

	system("cd bot13 && git pull origin #{$origin}")

	if not Dir.exists?($home + "/.bot13/")
		Dir.mkdir($home + "/.bot13/")
	end
	
	files = ["papi.rb","core.rb","plugins"]

	for f in files 
		system("cp #{$home}/bot13/#{f}","#{$home}/.bot13/#{f}")
	end

	f = File.open("#{$home}/.bot13/core.rb")
	s = f.readlines.join("\n")
	f.close
	eval(s)
	
end