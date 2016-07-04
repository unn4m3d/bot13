require 'optparse'
require 'telegram/bot'

lib 'lib/storage'
lib 'lib/perms'

module Bot13
	class Message < Telegram::Bot::Types::Message
		attr_accessor:_args,:_command
		def initialize(oc)
			oc.send("attribute_set").each{
				|attr|
				self.send(attr.name.to_s + "=",oc.send(attr.name)) #FIXME : It should be rewritten
			}
		end
	end


	class Bot
		attr_accessor	:tgbot,:plugins,:home,:config,:failsafe,:token,:permengine,:storage
		attr_reader		:handlers,:userinfo,:active_plugins

		def load_config(home)
			begin
				@config = JSON.parse File.read File.join(home+"/data/config.json")
			rescue => e
				@config ||= {}
				raise e
			end
		end

		def class_from_string(str)
			dinfo str
			dinfo str.split '::'
  		str.split('::').inject(Object) do |mod, class_name|
    		mod.const_get(class_name)
  		end
		end

		def listen(cmd:nil,perm:0,pname:nil,ignore_username:false,&b)
			@handlers << [b,cmd,perm,pname,ignore_username]
		end

		def initialize(token,home:File.expand_path("./"),failsafe:false,config:nil)
			@home = home
			@token = token
			@failsafe = failsafe
			@config = config
			load_config home unless config
			@tgbot = Telegram::Bot::Client.new(@token)
			@handlers = []
			#@tgbot = TgAPI::TgBot.new(@token)
			@plugins = Bot13::load_plg(@home+"/plugins")
			@active_plugins = []


			@permengine = PermEngine.new(class_from_string(@config['perms']['driver']['class']).new(*(@config['perms']['driver']['params'])))
			if @config['storage']['enable'] then
				@storage = SyncStorage.new(class_from_string(@config['storage']['driver']['class']).new(*(@config['storage']['driver']['params'])))
			end

		end

		def process_update(m)
			command,username,args = nil,nil,nil
			if m.text and m.text.start_with? "/","!"
				command = m.text[1..-1].split(" ",2)
				command,args = command[0],command[1]
				command,username = *(command.split("@",2)) if command.include? "@"
			end
			@handlers.each{
				|h|
				if h[1]
					if command and command == h[1]
						if not username or username == @userinfo['result']['username'] or h[4]
							if @permengine.allow?(m.from.id,m.chat.id,h[2],h[3])
								mesg = Message.new m
								mesg._command = command || ""
								mesg._args = args || ""
								h[0].call mesg
							end
						end
					end
				else
					h[0].call m
				end
			}
		end

		def api
			@tgbot.api
		end

		def store(key,value)
			@storage.set(key,value,false)
		end

		def unstore(key)
			@storage.get(key)
		end

		def start
			begin
				@plugins.each do |plg|
					@active_plugins << plg.new(self)
				end

				@tgbot.run do
					|b|
					@userinfo = b.api.get_me
					b.listen do
						|message|
						process_update message
					end
				end
			rescue Telegram::Bot::Exceptions::ResponseError => e
				raise e if not @failsafe or e.error_code == 401
				dcritical e.to_s
			rescue => e
				dcritical e.to_s
				dcritical e.backtrace.join("\n\t")
			end
		end

		def stop
			@permengine.close
			@storage.close if @storage
		end
	end
end
