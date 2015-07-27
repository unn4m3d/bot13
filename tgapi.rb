=begin
	Telegram Bot API
	v 1.0
=end
require 'net/http'
require 'curb'
require 'json'
require 'timers' #gem install timers
require 'uri'
$lid = 0
$imgmime = {
	".png" => "image/png",
	".gif" => "image/gif",
	".jpg" => "image/jpeg",
	".jpeg" => "image/jpeg"
}


module TgAPI
	
	class User
		attr_reader:id,:first_name,:last_name,:username
		def initialize(j)
			@id = j["id"]
			@first_name = j["first_name"]
			@last_name = j["last_name"]
			@username = j["username"]
		end
		def to_json
			return {"id"=>@id,"first_name"=>@first_name,"last_name"=>@last_name,"username"=>@username}
		end
	end
	
	class GroupChat < User
		attr_reader:title
		def initialize(j)
			if j["title"] then
				@title = j["title"]
			else
				super(j)
			end
		end
	end
	
	class Message
		attr_reader:message_id,:from,:date,:chat,:reply_to_message,:audio,:document,:photo,:sticker
		attr_reader:text,:video,:contact,:location,:new_chat_participant,:left_chat_participant
		attr_reader:new_chat_title,:new_chat_photo,:delete_chat_photo,:group_chat_created
		attr_reader:source
		attr_accessor:_args
		def initialize(j)
			#puts j.to_s
			@source = j
			@message_id = j["message_id"]
			@from = User.new(j["from"])
			@date = j["date"]
			@chat = GroupChat.new(j["chat"])
			@reply_to_message,@audio,@document,@photo = j["reply_to_message"],j["audio"],j["document"],j["photo"]
			@reply_to_message = Message.new(@reply_to_message) if @reply_to_message #Parsing as JSON if exists
			@sticker = j["sticker"]
			@text,@video,@contact,@location = j["text"],j["video"],j["contact"],j["location"]
			@new_chat_participant,@left_chat_participant = j["new_chat_participant"],j["left_chat_participant"]
			@new_chat_participant = User.new(@new_chat_participant) if @new_chat_participant
			@left_chat_participant = User.new(@left_chat_participant) if @left_chat_participant
			@new_chat_title,@new_chat_photo = j["new_chat_title"],j["new_chat_photo"]
			@delete_chat_photo,@group_chat_created = j["delete_chat_photo"],j["group_chat_created"]
		end
	end
	
	class ReplyKeyboardMarkup
		attr_accessor:keyboard,:resize_keyboard,:one_time_keyboard,:selective
		def initialize(j)
			@keyboard
		end
	end
	
	class Update
		attr_reader:update_id,:message
		def initialize(obj)
			@update_id,@message = obj["update_id"],Message.new(obj["message"])
		end
	end
	
	class TgMessageHandler
		attr_accessor:proc,:options
		def initialize(p,o)
			@proc,@options = p,o
		end
		def call(a)
			@proc.call(a)
		end
	end
	
	class TgBot < User
		public
		attr_reader:token,:tg
		attr_accessor:handlers,:state
		def query(func,args={})
			uri = URI("https://api.telegram.org/bot#{@token}/#{func}")
			uri.query = URI.encode_www_form(args)
			puts "[INFO] Query : #{uri.to_s}" unless func.match(/^getUpdates.*$/i)
			r = Net::HTTP.get_response(uri)
			j = JSON.parse(r.body)
			raise Exception.new(j) unless j["ok"]
			return j
		end
		
		def initialize(t)
			@token = t
			@handlers = []
			@tg=nil
		end
		
		def main
			update
		end	
		
		def start(interval=1)
			begin
				@tg.resume
				return
			end if @tg
			@tg = Timers::Group.new
			@tg.every(interval){
				main
			}
		end
		
		def pause
			@tg.pause
		end
		
		def stop
			@tg.cancel if @tg
			@tg = nil
		end
		
		def addhandler(h)
			puts "[INFO] Handler registered"
			r = @handlers.length
			@handlers.push(h)
			return r
		end
		
		def sendMessage(chat_id,text,dwpp=nil,rtmi=nil,rmu=nil)
			params = {"chat_id" => chat_id,"text"=>text}
			params["disable_web_page_preview"] = dwpp if dwpp
			params["reply_to_message_id"] = rtmi if rtmi
			params["reply_markup"] = rmu.to_json if rmu
			params.rehash
			return query("sendMessage",params)
		end
		
		def sendPhoto(chat_id,file,caption=nil,rtmi=nil,rmu=nil)
			sendChatAction(chat_id,"upload_photo")
			puts "[INFO] Uploading #{file}"
			c = Curl::Easy.new("https://api.telegram.org/bot#{@token}/sendPhoto")
			c.multipart_form_post = true
			c.http_post(Curl::PostField.content('chat_id',chat_id.to_s),Curl::PostField.file('photo',file){IO.read(file)})
			return JSON.parse(c.body_str)
		end
		
		def sendChatAction(chat_id,action)
			return query("sendChatAction",{"chat_id"=>chat_id,"action"=>action})
		end
		
		def update
			h = query("getUpdates",{"offset"=>$lid+1})
			if h["ok"] == true
				if h["result"].length < 1 then return end
				for m in h["result"] do
					for hn in @handlers
						if hn.options["raw"] then
							hn.call(m)
						else
							hn.call(Update.new(m))
						end
					end
				end
			else	
				puts "[CRITICAL] Error : #{h["description"]}"
			end 
		end
	end
end