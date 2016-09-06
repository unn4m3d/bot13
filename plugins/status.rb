class StatusPlugin < Bot13::Plugin
	register

	def name; "status" end
	def version; "0.0.1" end
	def author; "unn4m3d" end

	def settings_file; File.join(bot.home,"data","butthurt.json") end

	def set_butthurt(u,b)
		@butthurt[u.to_s] = b.to_f
		save_butthurt
	end

	def add_butthurt(u,v)
		set_butthurt(u,butthurt(u)+v)
	end

	def save_butthurt
		File.open(settings_file,"w") do |f| f.write(JSON.generate @butthurt) end
	end

	def load_butthurt
		@butthurt = JSON.parse File.read(settings_file)
	end

	def butthurt(u)
		@butthurt[u.to_s] || 0.0
	end

	def butthurt_level(u)
		case butthurt(u)
			when 0...10
				"будда"
			when 10...15
				"просветленный"
			when 15...20
				"зуб"
			when 20...35
				"котька"
			when 35...70
				"дикси"
			else
				"хелл"
		end
	end

	def initialize(bot)
		super bot
		@butthurt = {}
	
		if File.exists?(settings_file)
			load_butthurt
		else
			save_butthurt
		end	

		bot.listen(cmd:"status",pname:"status_func") do |msg|
			bot.api.send_message(
				chat_id: msg.chat.id,
				text: "Ваш уровень бугурта : *#{butthurt_level(msg.from.id)}*\nТемпература пукана *#{30 + 2*butthurt(msg.from.id) }*",
				parse_mode: "Markdown"
			)
		end

		bot.listen do |msg|
			if msg.text
				if msg.text.match(/[A-ZА-Я]/)
					add_butthurt(msg.from.id,10*(msg.text.chars.count{|s| s.match(/[A-ZА-Я]/)}/msg.text.size))
				else
					add_butthurt(msg.from.id,-0.01*msg.text.size) if butthurt(msg.from.id) > 0
				end
			end
		end
	end
end
