=begin
	Bot13 v 2.0.3A
	By S.Melnikov a.k.a. unn4m3d
	License : GNU GPLv3
	
	Changelog:
		v 2.0.3A #3
		>Added !restart command
		>Colorized !bandit 
	
		v 2.0.2A #2
		> Splitted API and Core
		> Documented API
		> Done NickList 
	
		v 2.0.1A #1
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
require 'IRC'
#Environment vars
$channels = ["#th1rt3en","#mapc"]
$server = "irc.ircnet.ru"
$port = 6688 #UTF-8 Support
$home = Dir.chdir{|path| path} #Dirty hack!!! =)
require $home + "/.bot13/api"


def comcb(event)
	ea = event.message.split(" ")
	if event.from == $userdata[0] then
		return
	end
	if not event.message.match(/^!.*$/) then
		return
	end
	if not event.channel then 
		event.channel = event.from 
	end
	if $cmds[ea[0]] != nil
		$cmds[ea[0]].execute(ea[1..-1],event.from,event.channel)
	else
		msg("No such command : #{ea[0]}, please type !help to list commands",event.from)
	end
end

def weechat_init
	$conn = IRC.new($userdata[0],$server,$port.to_s,$userdata[1])
	puts "Connecting to #{$server}:#{$port.to_s} (#{$userdata[0]}!#{$userdata[1]})"
	IRCEvent.add_callback('privmsg'){|e|
		if is_valid_chan(e.channel)
			comcb(e)
		end
		puts "Message from #{e.from} : \"#{e.message}\""
	}
	IRCEvent.add_callback('join'){
		|e|
		if is_valid_chan(e.channel)
			msg(getmsg('join').gsub(/`U`/,e.from),e.channel)
		end
		puts "#{e.from} has joined #{e.channel}"
	}
	IRCEvent.add_callback('quit'){
		|e|
		if is_valid_chan(e.channel)
			msg(getmsg('leave').gsub(/`U`/,e.from),e.channel)
		end
	}
	IRCEvent.add_callback('endofmotd'){
		|e|
		for c in $channels
			$conn.add_channel(c)
			$conn.send_action(c,getmsg("lvlup"))
		end
		puts "Connected succesfully"
	}
	IRCEvent.add_callback('353'){ #NAMES Reply
		|e|
		$udata = e.message
	}
	#$conn.start
	
	addcmd("!debug",5,Proc.new{
		|a,u,c|
		ll = 0
		hl = 128
		c = 10
		if a.length == 1
			c = a[0].to_i
		elsif a.length == 2
			c = a[0].to_i
			ll = a[1].to_i
			hl = a[1].to_i
		elsif a.length == 3
			c = a[0].to_i
			ll = a[1].to_i
			hl = a[2].to_i	
		elsif a.length == 4
			c = a[0].to_i
			ll = a[1].to_i
			hl = a[2].to_i
			u = a[3]
		end
		for i in [($debug.length-c)..-1]
			if $debug[i].level >= ll and $debug[i].level <= hl
				msg($debug[i].msg,u)
			end
		end
		
	},1)
	addcmd("!bot13",0,Proc.new{
		|a,u,c| msg("Bot-Th1rt3en v" + $version + " by " + $author, c)
	},10)
	addcmd("!restart",6,Proc.new{
		|a,u,c| restart
	},10)
	addhelp("!bot13","Displays bot info",[])
	$cmds.rehash()
	addcmd("!cmds",0,Proc.new{
		|a,u,c|
		for k in $cmds.keys()
			s = k
			if $cmdh[k]
				s += " - " + $cmdh[k].brief
			end
			msg(s,u)
		end
	},20)
	addhelp("!cmds", "Lists commands",[])
	addcmd("!random", 0, Proc.new{
		|a,u,c|
		if a.length == 0
			msg(Random.rand(10).to_s, c)
		elsif a.length == 1
			msg(Random.rand(Integer(a[0])).to_s,c)
		else
			msg((Integer(a[0])+ Random.rand(Integer(a[1]) - Integer(a[0]))).to_s,c)
		end
	},10)
	addhelp("!random", "Displays random number",
		["Usage : !random [a[,b]] \n",
		"Without args, it displays random number from 0 to 9\n",
		"With 1 arg, it displays number from 0 to a\n",
		"With 2 args, it displays number from a to b"])
	addcmd("!bandit", 0, Proc.new{
		|a,u,c|
		num = []
		num[0] = Random.rand(10)
		msg("#{$c}8,9[" + num[0].to_s + "|-|-]",c)
		num[1] = Random.rand(10)
		msg("#{$c}8,9[" + num.join("|") + "|-]",c)
		num[2] = Random.rand(10)
		m = "#{$c}8,9[" + num.join("|") + "]#{$c}"
		puts num.join
		if num[1] == num[0] and num[1] == num[2]
			m += " " + getmsg("win")
			b_set(num[0],u)
		else
			if num[1] != num[2] and num[1] != num[0] and num[0] != num[2]
					m += " " + getmsg("lose")
			else
				m += " Second chance"
				msg(m,c)
				if num[1] == num[2]
					num[0] = Random.rand(10)
				elsif num[0] == num[2]
					num[1] = Random.rand(10)
				elsif num[0] == num[1]
					num[2] = Random.rand(10)
				end
				m = "#{$c}8,9[" + num.join("|") + "]#{$c} "
				if num[1] == num[0] and num[1] == num[2]
					m += getmsg("win")
					b_set(num[0],u)
				else
					m += getmsg("lose")
				end
			end
		end
		msg(m,c)
		
	},60)
	
	addhelp("!bandit","One-arm bandit",[])
		
	addcmd("!winners", 0, Proc.new{
		|a,u,c|
		b_show(c)
	},10)
		
	addhelp("!winners", "Displays !bandit winners",[])
		
	addcmd("!motd", 0, Proc.new{
		|a,u,c|
		if a.length > 0
			$motd = a.join(" ")
		else
			msg($motd,c)
		end
	},10)
	addhelp("!motd", "Shows or sets message of the day",
		["Usage : !motd [<motd>]",
		"If <motd> is set, then sets motd",
		"Else, displays current motd"])
	addcmd("!help", 0, Proc.new{
		|a,u,c|
		if a.length == 0
			msg("#{$c}0,5=============[#{$c}5,0HELP#{$c}0,5]=============#{$c}",u)
			cmda = {}
			for k in $cmdh.keys
				msg("#{$c}0,5#{k+$c} - #{$cmdh[k].brief}",u)
			end
			msg("Type #{$c}0,5!help <command>#{$c} for further info", u)
			msg("#{$c}0,5===============================#{$c}",u)
		else
			msg("#{$c}0,5=============[#{$c}5,0HELP#{$c}0,5]=============#{$c}",u)
			for p in a
				if $cmdh[p]
					msg(p + " - " + $cmdh[p].brief,u)
					for l in $cmdh[p].text
						msg(l,u)
					end	
					msg("Aliases : #{$c}0,5#{aliases(p).join(",")+$c}",u)
				else
					msg(p + ": No help page",u)
				end
			end
			msg("#{$c}0,5===============================#{$c}",u)
		end
	},60)
		
	addcmd("!perm", 5, Proc.new{
		|a,u,c|
		if a.length == 1 
			if a[0] == "get"
				$conn.send_notice(u,"You have level #{$perms[u].to_s}")
			elsif a[0] == "show"
				for k in $perms.keys()
					msg(k + " " + $perms[k].to_s,u)
				end
			end
			
		elsif a.length == 2
			if a[0] == "set"
				Permissions.set(u,a[1].to_i)
			end
		elsif a.length > 2
			if a[0] == "set"
				Permissions.set(a[1],a[2].to_i)
			end
		end
	},5)
	addhelp("!perm","Permissions control",
		[
			"Usage : !perm(set [[<nick> ]<level>]|get|show)",
			"!perm set <level> - sets you lvl <level>",
			"!perm set <nick> <level> - sets user <nick> level <level>",
			"!perm get - shows your level, !perm show - shows levels"
		])
	addalias("!бот13", "!bot13")
	addalias("!рандом", "!random")
	addalias("!бандит", "!bandit")
	addalias("!бандиты", "!winners")
	addalias("!хелп", "!help")
	if not Dir.exists?($home + "/.bot13/")
		Dir.mkdir($home + "/.bot13/")
	end
	if not File.exists?($home + "/.bot13/bandit.cfg")
		b_save()
	end
	if not File.exists?($home + "/.bot13/perms.cfg")
		Permissions.save()
	end
	b_load()
	Permissions.load()
	if not Dir.exists?($home + "/.bot13/plugins/")
		Dir.mkdir($home + "/.bot13/plugins")
	end
	papiinit	
end

def uninit
	IRCConnection.quit
end

def restart
	uninit
	Kernel.exec("ruby #{__FILE__}")
end

dinfo("[INFO] Starting...")
weechat_init
dinfo("[INFO] Started successfully")

$conn.start
