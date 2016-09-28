require 'optparse'
require 'telegram/bot'
require 'find'

lib 'lib/storage'
lib 'lib/perms'

module Bot13
	class Message < Telegram::Bot::Types::Message
		attr_accessor:_args,:_command
		def initialize(oc)
			oc.send("attribute_set").each{
				|attr|
				self.send(attr.name.to_s + "=",oc.send(attr.name)) 
			}
		end
	end

	class Bot
		attr_accessor	:tgbot,:plugins,:home,:config,:failsafe,:token,:permengine,:storage
		attr_reader		:handlers,:userinfo,:active_plugins

		def addins_path
			File.join(@home,"lib","addins")
		end
		def load_config(home)
			begin
				@config = JSON.parse File.read File.join(home+"/data/config.json")
			rescue => e
				@config ||= {}
				raise e
			end
		end

		def class_from_string(str)
  			str.split('::').inject(Object) do |mod, class_name|
    			mod.const_get(class_name)
  			end
		end

		def listen(cmd:nil,perm:0,pname:nil,ignore_username:false,raw:false,&b)
			@handlers << [b,cmd,perm,pname,ignore_username]
		end

		def listen_error(&b)
			@error_handlers << [b]
		end

		def initialize(token,home:File.expand_path("./"),failsafe:false,config:nil)
			@home = home
			@error_handlers = []
			@token = token
			@failsafe = failsafe
			@config = config
			load_config home unless config
			dinfo "Searching for addins in #{addins_path}"
			Find.find(addins_path) do |path|
				begin
					dinfo "Found #{path.sub(addins_path,'')} in addins folder"
					if File.extname(path).match(/\.rb$/i)
						dinfo "Loading..."
						Kernel::load path
					end
				rescue => e
					dcritical "Failed to load!"
					dcritical e.inspect
					dcritical e.backtrace.join "\n\t"
				end
			end
			dinfo "Launching bot"

			@tgbot = Telegram::Bot::Client.new(@token)
			@handlers = []
			#@tgbot = TgAPI::TgBot.new(@token)
			@plugins = Bot13::load_plg(@home+"/plugins")
			@active_plugins = []

			dinfo "Launching permissions"
			@permengine = PermEngine.new(class_from_string(@config['perms']['driver']['class']).new(self,*(@config['perms']['driver']['params'])))
			if @config['storage']['enable'] then
				dinfo "Launching storage"
				@storage = Storage::SyncStorage.new(class_from_string(@config['storage']['driver']['class']).new(self,*(@config['storage']['driver']['params'])))
			else
				dinfo "Storage is disabled, skipping"
			end

		end

		def process_update(m)
			if m.kind_of? Telegram::Bot::Types::Message
				if m.text && m.text.start_with? "/","!"
					command,args = m.text[1..-1].split(" ",2)
					command,username = command.split("@",2) if command && command.include? "@"
				end
			end
			
			if m.kind_of? Telegram::Bot::Types::Message
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
			else
				@handlers.select{|x| x[1].nil? }.each{|x| x.first.call m}
			end
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

		def on_error(c,e)
			for h in @error_handlers do
				result = h.first.call(c,e)
				case result
				when :catched
					return
				when :passed
					raise e
				end
			end
		end

		def start
			@plugins.each_with_index do |plg,i|
				dinfo "Loading plugin #{i+1}/#{Plugin.plugins.size}..."
				begin
					plugin =  plg.new(self)
					dinfo "Initialized #{plugin.name} v#{plugin.version}"
					@active_plugins << plugin
					dinfo "Pushed #{plugin.name}"
				rescue => e
					dcritical "Failed to load !"
					dcritical e.to_s
					dcritical e.backtrace.join "\n\t"
				end
			end

			@tgbot.run do
				|b|
				@userinfo = b.api.get_me
				b.listen do
					|message|
					begin
						process_update message
					rescue => e
						on_error message, e
					end
				end
			end
		end

		def stop
			@permengine.close
			@storage.close if @storage
		end
	end
end
