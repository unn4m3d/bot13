require 'json'

module Bot13

	class Plugin
		class << self
			attr_accessor :plugins
			def register
				Plugin.plugins ||= []
				Plugin.plugins << self
			end
		end

		attr_reader :bot

		def bot=(b)
			@bot ||= b
		end

		def initialize(bot)
			@bot ||= bot
		end

		def name; self.class.name.downcase.gsub(/::/,'_') end
		def version; "0.0.1" end
		def version_id; 0 end
		def author; "unknown" end
		def license; "MIT" end

		def brief(file="unknown")
			#dinfo "Calling #{name}#brief"
			return "[#{file}] #{name} v#{version} by #{author}"
		end

		def to_s(file="unknown")
			"#{brief file}\nLicense : #{@license}\n\n#{@desc}"
		end
	end

	def load_plg(dir=File.join($home,'plugins'))
		dinfo "Loading plugins..."
		#plg = {}
		for d in Dir.entries(dir) do
			unless File.directory?(File.join(dir,d)) #TODO : Loading plugins from directories
				if d.match(/\.(rb|plg)$/i) then
					dinfo "Preloaded plugin #{d}"
					require File.join(dir,d)
				end
			end
		end
		return Plugin.plugins
	end

	module_function:load_plg
end
