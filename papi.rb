=begin
	Plugin API v 2.0 for Bot13 
=end
$home = nil
$plugins = []
class Plugin
	attr_reader:name,:version,:author,:license
	attr_accessor:desc,:filename
	def initialize(j,f)
		begin
			@name,@version,@author,@license = j["name"],j["version"],j["author"],j["license"]
			@desc = j["description"]
		end if j
		@filename = f
	end
	def to_s
		return "\"#{@name}\" (#{File.basename(@filename)}) v#{@version} by #{@author}\n#{@desc}\nPublished under #{license}"
	end
end

def loadfile(f)
	fl = File.open(f)
	code = fl.readlines.join("\n")
	fl.close
	eval code
end

def loadinfo(f)
	if File.exist?(f+".json")
		fl = File.open(f+".json")
		jo = JSON.parse(fl.readlines.join("\n"))
		fl.close
		for pl in jo["plugins"] do
			$plugins.push(Plugin.new(pl,f))
		end
	else
		$plugins.push(Plugin.new(nil,f))
	end
end

def papiinit(dir="./plugins")
	unless File.exist?(dir)
		dcritical("[CRITICAL] No plugins folder #{dir}. Plugins are disabled")
		return
	end
	addcmd("plugins",1,Proc.new{
		|a,m|
		c = m.source["chat"]["id"]
		c = $cid unless c
		if a.length == 0
			rt = ""
			for p in $plugins
				rt += "#{p.name} [#{File.basename(p.filename)}]\n"
			end	
			msg(rt,c)
		elsif a.length == 1
			for p in $plugins
				begin
					msg(p.to_s,c)
					break
				end if (p.name.downcase == a[0].downcase or p.filename.downcase == a[0].downcase)
			end
		end
	},60)
	$help["plugins"] = HelpPage.new("/plugins","plugins info","Usage : /plugins [<name>]")
	for _k in Dir.entries(dir) do
		k = dir + "/" + _k
		unless File.directory?(k)
			unless k.match(/~$/)
				unless k.match(/\.json$/)
					loadfile(k) 
					dinfo "[INFO] Loaded file #{k}"
					loadinfo(k)
				end 
			end
		end
	end
end
