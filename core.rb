=begin
	Bot13 v 3.0 TA (Telegram version)
	By S.Melnikov a.k.a. unn4m3d
	License : GNU GPLv3
	
	Changelog:
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
$cid = "-11333160"
$rf = {
	"cfg"=>$home+"/.bot13_telegram/config.json",
	"pmc"=>$home+"/.bot13_telegram/perms.cfg",
	"api"=>$home+"/.bot13_telegram/api.rb",
	"tga"=>$home+"/.bot13_telegram/tgapi.rb"
}
def checkfile(file,dt = "",&h)
	unless File.exists?(file)
		if block_given?
			yield file
		else
			puts "[WARNING] #{file} is missing, initializing it with `#{dt}`"
			f = File.open(file,"w")
			f.write(dt)
			f.close
		end
	end
end

checkfile($home+"/.bot13_telegram"){
	|f|
	puts "[CRITICAL] System dir #{f} is missing!"
	Dir.mkdir(f)
}

checkfile($rf["tga"]){
	|f|
	puts "[FATAL] API file #{f} is missing!"
	Kernel.exec("echo Halted")
}
checkfile($rf["api"]){
	|f|
	puts "[FATAL] API file #{f} is missing!"
	Kernel.exec("echo Halted")
}
require $home + "/.bot13_telegram/tgapi"
require $home + "/.bot13_telegram/api"

def msgcb(u)
	if u.update_id.to_i > $lid
		puts "[INFO] Parsing msg ID #{u.update_id.to_s} : #{u.message.text}"
		return unless u.message.text
		$lid = u.update_id
		if u.message.text.match(/^[!\/].+$/) then
			#If the message is command
			cmd = u.message.text.sub(/^[!\/]([^\s]+).*$/){$1}
			args = u.message.text.split(" ")[1..-1]
			if $cmds[cmd] then
				$cmds[cmd].execute(args,u.message)
			elsif $cmds["!"+cmd] then
				$cmds["!"+cmd].execute(args,u.message)
			elsif $cmds["/"+cmd] then
				$cmds["/"+cmd].execute(args,u.message)
			else
				puts "[WARNING] No such command : #{cmd}"
			end
		end
	end
end

checkfile($rf["pmc"]){
	|f|
	Permissions.save
}

checkfile($rf["cfg"]){
	|f|
	puts 
	exec("echo '[FATAL] : #{f} is missing ! Please fill it with config'")
}
Permissions.load
f = File.open($rf["cfg"])
$config = JSON.parse(f.readlines.join("\n"))
f.close
if $config["token"] == nil
	puts "[FATAL] No bot authorization token in #{$rf["cfg"]}"
	exec "echo Halted"
end
$token = $config["token"]
if $config["chats"] == nil or $config["chats"] == []
	puts "[WARNING] No chat IDs in #{$rf["cfg"]}"
end
$chats = $config["chats"]
if $config["last_update"]
	$lid = $config["last_update"]
else
	puts "[WARNING] No last update ID in config, initializing with 0"
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
puts "[INFO] Bot started"
loop { $bot.tg.wait}




