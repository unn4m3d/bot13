#!/usr/bin/ruby

$home = File.dirname(File.expand_path(__FILE__))

module ExitCodes
	OK 			= 0
	LIBMISSING	= 1
	INTERNALERR = 2
	INVALIDCFG  = 3
end

module Bot13
	VERSION = "3.2.2 Tg Edition Alpha"
end
require 'optparse'
require 'json'

$options = {}


begin
	puts "[INFO] Loading Bot-Th1rt3en v#{Bot13::VERSION}"
	OptionParser.new do |o|
		o.banner = "Bot-Th1rt3en v#{Bot13::VERSION}"
		o.on('-HHOME','--home=HOME','Change home'){|h| $home=h}
		o.on('-f','--failsafe','Catch exceptions with restart'){$options[:f] = true}
		o.on('-h','--help','Print this help'){puts o; exit 0}
		o.on('-dLEVEL','--debug=LEVEL','Minimal message level'){|l|$options[:d]=l.to_i}
		o.on('-tTOKEN','--token=TOKEN','Set token'){|t|$options[:t]=t}
	end.parse!

	unless File.exists?(File.join($home,'lib','debug.rb'))
		puts '[FATAL] Cannot load library lib/debug.rb'
		exit ExitCodes::LIBMISSING
	end

	require File.join($home,'lib','debug')

	dinfo "Debug library loaded successfully"
	
	lib 'lib/load'
	lib 'lib/tgapi'
	lib 'lib/plugins'
	lib 'lib/cmdengine'
	lib 'lib/perms'
	
	def restart
		puts '[INFO] Restart!'
		begin
			_ul
		ensure
			exec "#{__FILE__} #{ARGV.join ' '}"
		end
	end
	
	$config = JSON.parse File.read File.join($home,'data/config.json')
	
	
	unload do
		$config['lid'] =$bot.uid
		File.open(File.join($home,'data/config.json'),'w') do
			|f|
			f.write JSON.generate ($config)
		end
	end
	
	unless $config['token'] or $options[:t]
		dfatal "No token specified"
		exit ExitCodes::INVALIDCFG
	end
	
	unless $config['lid']
		dwarning "No Last Update ID specified, returning to 0"
		$config['lid'] = 0
	end
	
	unless File.exists?(File.join($home,"temp"))
		Dir.mkdir(File.join($home,"temp"))
		dinfo "Creating directory temp/"
	end
	
	unless File.exists?(File.join($home,"data","permissions.json"))
		dwarning("No permissions data found!")
		Bot13::Perms.save
	end
	
	unless File.exists?(File.join($home,"data","channels.json"))
		dwarning("No channel permissions data found!")
		Bot13::ChanPerms.save
	end
	
	Bot13::Perms.load
	Bot13::ChanPerms.load
	
	begin
		require 'curb'
		$ldcurb=true
		dinfo "Loaded curb successfully"
	rescue LoadError
		$ldcurb=false
		dwarning "Cannot load curb, image uploading disabled"
	end
	
	token = ($options[:t] || $config['token'])
	
	$bot = TgAPI::TgBot.new token,$ldcurb
	
	$cmdengine = Bot13::CmdEngine.new
	
	$bot.addhandler(TgAPI::TgMessageHandler.new(
		Proc.new{
			|u|
			if u.update_id > $bot.uid
				$bot.uid = u.update_id
				$config['lid'] = $bot.uid
				if u.message.text
					dinfo "Processing update #{u.update_id} : <#{u.message.from.username}> #{u.message.text}"
					cmd = $cmdengine.parse u.message
					u.message._args = u.message.text.gsub(/^[^\s]+\s/){dinfo "Deleting text #{$1}";''}
					if cmd
						if Bot13::Perms.get(u.message.source['from']['id'].to_s,u.message.source['chat']['id'].to_s) >= $cmdengine.cmds[$cmdengine.get_original_name(cmd.name)].perm
							if $cmdengine.timer.allow?(cmd.name,u.message.source['from']['id'].to_s)
								if Bot13::ChanPerms.allow?($cmdengine.get_original_name(cmd.name),u.message.source['chat']['id'].to_s)
									cmd.call($cmdengine,u.message)
								else
									$bot.sendMessage(
										u.message.source['chat']['id'],
										"Disalowed in this chat",
										nil,
										u.message.id
									)
								end
							end
						else
							$bot.sendMessage(
								u.message.source['chat']['id'],
								"You are not permitted to run this",
								nil,
								u.message.id
							)
						end
					end
				else
					dwarning "Skipping update #{u.update_id}"
				end
			end
		},{}
	))
	
	$plugins = Bot13::load_plg 
	
	_ld
	$plugins.each{|k,v| v.load}
	unload{$plugins.each{|k,v|v.unload}}
	
	$bot.start
	

rescue => e
	puts "[FATAL] #{(e.class.name.gsub(/([A-Z])/){"_#{$1}"}).upcase.gsub(/::/,'_')}"
	if $options[:f] and not e.kind_of? LoadError then #Restart if failsafe mode enabled and this is not a LoadError
			restart
	else
			_ul
			raise e
	end
end

_ul
