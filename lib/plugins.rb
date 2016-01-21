require 'json'

module Bot13

	class PluginFile
		attr_accessor:plugins,:file,:lb,:ub,:cfg
		def initialize(f='.dummy')
			@file = f
			@plugins = []
			@lb = []
			@ub = []
		end
		
		def push(p)
			@plugins.push p
		end
	
		def brief(md=false)
			s = ""
			#dinfo "Calling #{self}#brief"
			@plugins.each do |p|
				s += p.brief(@file,md)+"\n"
			end
			s
		end
		
		def load
			_ld(@lb,@file,@cfg)
		end
		
		def unload
			_ld(@lb,@file)
		end

		def to_s
			return JSON.generate(@plugins)
		end
	end

	class Plugin
		attr_accessor:name,:author,:license,:version,:desc
		def initialize(n,a,l,v,d)
			@name,@author,@license,@version,@desc = n,a,l,v,d
		end
		def brief(file="unknown",md=false)
			#dinfo "Calling #{name}#brief"
			return "[#{file}] #{@name} v#{@version} by #{@author}"
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
					plg[d] ||= PluginFile.new(d)
					plg[d].lb = $load.clone; $load = []
					plg[d].ub = $unload.clone; $unload = []
				elsif d.match(/\.(rb|plg)\.json$/i) then
					n = d.sub(/^(.*)\.json$/i){$1}
					dinfo "Found data for #{n}"
					if File.exists?(File.join(dir,n))#if plg.has_key? n then
						plg[n] ||= PluginFile.new n
						data = JSON.parse File.read File.join(dir,d)
						#dinfo data.to_json
						for p in data['plugins']
							plg[n].push Plugin.new(p['name'],p['author'],p['license'],p['version'],p['description'])
							dinfo "Loaded data for [#{n}] #{p['name']}"
						end
						plg[n].cfg = data['config'] if data['config']
					else
						dinfo "Skipping because can't find plugin file"
					end
					dinfo "Loaded data for #{n}"
				end
			end
		end
		return plg
	end

	module_function:load_plg
end
