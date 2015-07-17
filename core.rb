=begin
	Bot13 v 3.1 TA (Telegram Edition)
	By unn4m3d
	License : GNU GPLv3
=end
#Environment vars
$home = File.dirname(File.expand_path(__FILE__))
$cid = nil
$rf = {
	"cfg"=>"data/config.json",
	"pmc"=>"data/perms.json",
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
checkfile($rf["pmc"]){
	|f|
	dcritical "[CRITICAL] Permissions data is missing! Restoring it"
	File.open($rf["pmc"],"w") do
		|f|
		f.puts JSON.generate(
			{
				"users"=>{".default"=>0},
				"chanrules"=>{}
			}
		).gsub(/([\[\]{}])\s*/){$1+"\n"}
	end
}
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
		dinfo "[INFO] Processing update ID #{u.update_id.to_s} : #{u.message.text}"
		return unless u.message.text
		$lid = u.update_id
		if u.message.text.match(/^\/.+$/) then
			#If the message is command
			cmd = u.message.text.gsub(/\n/,'').sub(/^(\/[^\s\n\/]+)\s.*$/){$1}
			cmd = cmd.split("@")[0]
			_text = u.message.text.sub(cmd,'').sub(/^\/@[^@\s]\s/,'')
			u.message._args = _text
			args = u.message.text.split(/\s/)[1..-1]
			puts "[INFO] Args : #{args.join " "}"
			if $cmds[cmd] then
				$cmds[cmd].execute(args,u.message)
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

#FIXME: It doesn't work through File#puts and other std things when trapping an interrupt
def save_cfg
	$config["last_update"] = $lid
	system "echo '#{JSON.generate($config)}' > #{$rf["cfg"]}"
end

def restart
	save_cfg
	exec("ruby #{__FILE__}")
end

Signal.trap("TERM"){
	save_cfg
	exec "echo Terminated"
}
Signal.trap("INT"){
	save_cfg
	exec "echo Interrupted"
}
begin
	$bot = TgAPI::TgBot.new($token)
	$bot.addhandler(TgAPI::TgMessageHandler.new(Proc.new{|u|msgcb(u)},{}))
	$bot.addhandler(TgAPI::TgMessageHandler.new(Proc.new{|u|if u["message"]["text"] and u["message"]["text"].include? "@th1rt3en_bot" then msg("What?",u["message"]["chat"]["id"].to_s) end},{"raw"=>true}))
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
		msg(t,cc) if t and t != ""
	},1)
	addcmd("update",2,Proc.new{
		|a,m|
		arg = "-r"
		arg = a[0] if a[0]
		msg(`./update.sh #{arg}` + "\nECODE #{$?}" ,m.source["chat"]["id"])
		restart
	},1)
	$help["bot13"] = HelpPage.new("/bot13","prints bot's version","")
	$help["help"] = HelpPage.new("/help","prints help","Usage : /help [page]")
	dfatal("[FATAL] No chats are specified") unless $cid
	dinfo "[INFO] Bot started"
	#msg("pic\u200f123.exe","-11333160") #Unicode test
	begin
		dinfo "[INFO] Loading plugins..."
		papiinit
	end unless $plugins_disabled
	loop { $bot.tg.wait}
rescue=> e
	puts e
	puts "[RESTARTING]"
	restart
end




