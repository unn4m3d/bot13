class CorePlugin < Bot13::Plugin
	register

	def initialize(bot)
		super bot

		bot.listen(cmd:"bot13",ignore_username:false,pname:"corefunc"){
			|msg|
			bot.api.send_message(
				chat_id:msg.chat.id,
				text:"Bot13 v#{Bot13::VERSION} by @unn4m3d"
			)
		}

		bot.listen(cmd:"plugins",pname:"corefunc"){
			|msg|
			bot.api.send_message(
				chat_id:msg.chat.id,
				text: "Plugins:\n" + bot.active_plugins.inject(""){|memo,a| memo + "> #{a.brief("+")}\n"}
			)
		}
	end

	def author; "unn4m3d" end
	def version; Bot13::VERSION end
end
