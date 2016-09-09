class EDisplayPlugin < Bot13::Plugin 
	register

	include Telegram::Bot::Types

	def name; "errordisplay" end
	def author; "unn4m3d" end
	def version; "0.0.1" end

	def initialize(bot)
		super bot

		@exceptions = {}
		@lockobj = Mutex.new

		bot.listen_error{
			|cause,exception|

			def get_cause_cid(m)
				case m
				when CallbackQuery
					md = m.data.match(/^edisp_(?<action>einfo|trace|short) (?<num>\d+)$/)
					if md and @exceptions[md[:num].to_i]
						get_cause_cid @exceptions[md[:num].to_i].first
					else
						dwarning "[EDisplay] Cannot determine source chat of message (W_EXPIRED)"
						dinfo "[EDisplay] Using sender id " 
						return m.from.id
					end
				when Message 
					m.chat.id
				end
			end

			def get_cause_id(m)
				case m
				when CallbackQuery
					m.id
				when Message
					m.message_id
				end
			end

			#@lockobj.synchronize do

				loc = exception.backtrace_locations.select{|x| x.absolute_path.match(bot.home)}.first
				reply = bot.api.send_message(
					chat_id:get_cause_cid(cause),
					text:exception.to_s + "\n\n#{loc.absolute_path}\nat #{loc.lineno}", 
					reply_markup: InlineKeyboardMarkup.new(
						inline_keyboard: [
							InlineKeyboardButton.new(text:"Trace",callback_data:"edisp_trace #{get_cause_id cause}"),
							InlineKeyboardButton.new(text:"Exception Info", callback_data:"edisp_einfo #{get_cause_id cause}")
						]
					)
				)

				@exceptions[get_cause_id(cause).to_i] = [cause,exception,reply]
			#end 
		}

		bot.listen do 
			|msg|

			if msg.kind_of? Telegram::Bot::Types::CallbackQuery then
				md = msg.data.match(/^edisp_(?<action>einfo|trace|short) (?<num>\d+)$/)
				if md then
					num = md[:num].to_i
					if @exceptions[num] then
						cause = @exceptions[num].first
						btns = [
							InlineKeyboardButton.new(text:"Trace",callback_data:"edisp_trace #{get_cause_id cause}"),
							InlineKeyboardButton.new(text:"Exception Info", callback_data:"edisp_einfo #{get_cause_id cause}")
						]
						txt = @exceptions[num][1].to_s
						case md[:action]
						when "trace"
							btns = [
								InlineKeyboardButton.new(text:"Shorten",callback_data:"edisp_short #{get_cause_id cause}"),
								InlineKeyboardButton.new(text:"Exception Info", callback_data:"edisp_einfo #{get_cause_id cause}")
							]
							txt = @exceptions[num][1].backtrace.join("\n\t")
						when "einfo"
							btns = [
								InlineKeyboardButton.new(text:"Shorten",callback_data:"edisp_short #{get_cause_id cause}"),
								InlineKeyboardButton.new(text:"Trace", callback_data:"edisp_trace #{get_cause_id cause}")
							]
							txt = @exceptions[num][1].inspect
						end
						cd = @exceptions[num].last['result']
						cid = cd['chat']['id']
						bot.api.edit_message_text(
							message_id:cd["message_id"],
							chat_id:cid,
							text:txt,
							reply_markup: InlineKeyboardMarkup.new(inline_keyboard:btns)
						)
					else
						bot.api.answer_callback_query(callback_query_id:msg.id,text:"This error is no longer available")
					end
				end
			end
		end

		bot.listen(cmd:"etest"){
			|msg|
			raise StandardError.new("Test!")
		}
	end
end