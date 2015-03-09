=begin
	Plugin API for Bot13 v1.6 Beta
	How to install :
		On Linux, put papi.rb into ~/.bot13/ directory
		On Windows, put it into %APPDATA%/.bot13
=end

def loadfile(file)
	f = File.open(file)
	eval(f.readlines.join("\n"))
	f.close
end

def papiinit
	plugins = Dir.entries($home + "/.bot13/plugins")
	for p in plugins
		p = $home + "/.bot13/plugins/" + p
		if File.directory?(p)
			next
		end
		loadfile(p)
	end
end
