=begin
	Bot13 v 3.0.1 TA (Telegram Edition)
	By S.Melnikov a.k.a. unn4m3d
	License : GNU GPLv3
	
	Changelog:
		v 3.0.2 TA
		> Implemented PAPI v 2.0
		> Upgraded TgAPI
	
		v 3.0.1 TA
		> Added /help
		> No answers printed on getUpdates<br>
	
		v 3.0TA
		> Refactored for Telegram
	
		v 2.0.3IA #3
		>Added !restart command
		>Colorized !bandit 
	
		v 2.0.2IA #2
		> Splitted API and Core
		> Documented API
		> Done NickList 
	
		v 2.0.1IA #1
		> Fixed some minor bugs
		> Now can do some commands in private chat
	
		v 2.0A #0
		> Now can work outside of weechat
		> Has not UI
	
		v 1.7.1B(#10) by unn4m3d
		>New help format
		>Colorized a bit
		>Added help
		>Fixed some bugs
		
		v 1.7B(#9) by unn4m3d
		>Now can work on several channels
		>Upgraded bandit saving algorythm
		>Upgraded !help
		>Upgraded !cmds
		>Upgraded bandit
		>Added Reactions
	
		v 1.6.2B(#8) by unn4m3d
		>Upgraded nicklist (now can list users)
		>Fixed bug in social plugin
		
		v 1.6.1B(#7) by unn4m3d
		>Added nicklist API
	
		v 1.6B(#6) by unn4m3d
		>Added PluginAPI
		
		v 1.5B(#5) by unn4m3d
		>Added permissions
		>Every command has its own timeout
		>Now can only execute commands at one channel (Will be fixed later)
	
		v 1.4A(#4) by unn4m3d
		>Added !help command
		>Upgraded !motd command
		>Messages when user joins
		>Upgraded parser (Now you can use e.g. !lol and !lold, and it can be different commands)
		>Now bot can be switched off
		
		v 1.3A(#3) by unn4m3d
		>Random messages
		>Added !motd command
		>Added /sbm command (Sets motd)
		>Timeout between commands
		>Refactored some lines
		>Fixed a bug with table of records
		
		v 1.2A(#2) by unn4m3d
		>New bandit algorythm!
		>Fixed a bug in a cmd params  (that passed username instead of nick)
		
		v 1.1A(#1) by unn4m3d
		>Added !bandit and !winners cmds
		>Added !random command
		>Added !cmds command
		>Fixed bugs
		>Upgraded parser (Now parses channel name, and reads correctly #,!,: symbols)
		
		v 1.0A(#0) by unn4m3d
		>First release
=end
#Environment vars
$home = Dir.chdir{|path| path} #Dirty hack!!! =)
$cid = nil
$rf = {
	"cfg"=>"config.json",
	"pmc"=>"perms.cfg",
	"api"=>"api.rb",
	"tga"=>"tgapi.rb",
	"pla"=>"papi.rb",
}
def checkfile(file,dt = "",&h)
	unless File.exists?(file)
		if block_given?
			yield file
		else
			dwarning "[WARNING] #{file} is missing, initializing it with `#{dt}`"
			f = File.open(file,"w")
			f.write(dt)
			f.close
		end
	end
end

checkfile($rf["tga"]){
	|f|
	dfatal "[FATAL] API file #{f} is missing!"
}
checkfile($rf["api"]){
	|f|
	dfatal "[FATAL] API file #{f} is missing!"
}
require_relative "tgapi"
require_relative "api"
$plugins_disabled = false
checkfile($rf["pla"]){
	|f|
	dcritical "[CRITICAL] Plugin loader `#{f}` is missing! Plugins are disabled"
	$plugins_disabled = true
}
_home = $home
require_relative "papi" unless $plugins_disabled
$home = _home

def msgcb(u)
	if u.update_id.to_i > $lid
		dinfo "[INFO] Parsing msg ID #{u.update_id.to_s} : #{u.message.text}"
		return unless u.message.text
		$lid = u.update_id
		if u.message.text.match(/^\/.+$/) then
			#If the message is command
			cmd = u.message.text.sub(/^\/([^\s]+).*$/){$1}
			args = u.message.text.split(" ")[1..-1]
			puts "[INFO] Args : #{args.join " "}"
			if $cmds[cmd] then
				$cmds[cmd].execute(args,u.message)
			elsif $cmds["!"+cmd] then
				$cmds["!"+cmd].execute(args,u.message)
			elsif $cmds["/"+cmd] then
				$cmds["/"+cmd].execute(args,u.message)
			else
				dwarning "[WARNING] No such command : #{cmd}"
			end
		end
	end
end

checkfile($rf["pmc"]){
	|f|
	dwarning "[WARNING] Missing #{$rf["pmc"]}"
	Permissions.save
}

checkfile($rf["cfg"]){
	|f|
	dfatal"[FATAL] : #{f} is missing ! Please fill it with config"
}
Permissions.load
f = File.open($rf["cfg"])
$config = JSON.parse(f.readlines.join("\n"))
f.close
if $config["token"] == nil
	dfatal "[FATAL] No bot authorization token in #{$rf["cfg"]}"
end
$token = $config["token"]
if $config["chats"] == nil or $config["chats"] == []
	puts "[WARNING] No chat IDs in #{$rf["cfg"]}"
end
$chats = $config["chats"]
$cid = $chats[0] if $chats[0]
if $config["last_update"]
	$lid = $config["last_update"]
else
	dwarning "[WARNING] No last update ID in config, initializing with 0"
	$lid = 0
end

#FIXME: It doesn't work through File#puts and other std things
def save_cfg
	$config["last_update"] = $lid
	system "echo '#{JSON.generate($config)}' > #{$rf["cfg"]}"
end

Signal.trap("TERM"){
	save_cfg
	exec "echo Terminated"
}
Signal.trap("INT"){
	save_cfg
	exec "echo Interrupted"
}

$bot = TgAPI::TgBot.new($token)
$bot.addhandler(TgAPI::TgMessageHandler.new(Proc.new{|u|msgcb(u)},{}))
$bot.start
addcmd("bot13",0,Proc.new{
	|a,m|
	cc = m.source["chat"]["id"]
	cc = $cid unless cc
	msg("Bot-Th1rt3en #{$version} by #{$author}",cc.to_i)
},10)
addcmd("help",0,Proc.new{
	|a,m|
	cc = m.source["from"]["id"]
	cc = $cid unless cc
	t = cht
	t = cht(a[0]) if a[0]
	msg(t,cc)
},1)
$help["bot13"] = HelpPage.new("/bot13","prints bot's version","")
$help["help"] = HelpPage.new("/help","prints help","Usage : /help [page]")
dfatal("[FATAL] No chats are specified") unless $cid
dinfo "[INFO] Bot started"
begin
	dinfo "[INFO] Loading plugins..."
	papiinit
end unless $plugins_disabled
loop { $bot.tg.wait}




