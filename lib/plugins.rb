require 'json'

module Bot13

	class PluginFile
		attr_accessor:plugins,:file,:lb,:ub,:cfg
		def initialize(f='.dummy')
			@file = f
			@plugins = []
		end
		
		def push(p)
			@plugins.push p
		end
	
		def brief
			s = ""
			@plugins.each do |p|
				s += p.brief(@file)+"\n"
			end
			s
		end
		
		def load
			_ld(@lb,@file,@cfg)
		end
		
		def unload
			_ld(@lb,@file)
		end
	end

	class Plugin
		attr_accessor:name,:author,:license,:version,:desc
		def initialize(n,a,l,v,d)
			@name,@author,@license,@version,@desc = n,a,l,v,d
		end
		def brief(file="unknown")
			"[#{file}] #{@name} v#{@version} by #{@author}"
		end
	
		def to_s(file="unknown")
			"#{brief}\nLicense : #{@license}\n\n#{@desc}"
		end
	end

	def load_plg(dir=File.join($home,'plugins'))
		dinfo "Loading plugins..."
		plg = {}
		for d in Dir.entries(dir) do
			unless File.directory?(File.join(dir,d)) #TODO : Loading plugins from directories
				if d.match(/\.(rb|plg)$/i) then
					dinfo "Preloaded plugin #{d}"
					require File.join(dir,d)
					plg[d] = PluginFile.new(d)
					plg[d].lb = $load.clone; $load = []
					plg[d].ub = $unload.clone; $unload = []
				elsif d.match(/\.(rb|plg)\.json$/i) then
					n = sub(/^(.*)\.json$/i){$1}
					if plg.has_key? n then
						data = JSON.parse File.read File.join(dir,d)
						for p in data['plugins']
							plg[n].push Plugin.new(p['name'],p['author'],p['license'],p['version'],p['description'])
						end
						plg[n].cfg = data['config'] if data['config']
					end
					dinfo "Loaded data for #{n}"
				end
			end
		end
		return plg
	end

	module_function:load_plg
end
