=begin
	Bot13 v 2.0.1 IA
	By S.Melnikov a.k.a. unn4m3d
	License : GNU GPLv3
	
	Changelog:
		v 2.0.1 Independent Alpha #1
		> Fixed some minor bugs
		> Now can do some commands in private chat
	
		v 2.0 Independent Alpha #0
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
$channels = ["#th1rt3en"]
$server = "irc.ircnet.ru"
$port = 6688 #UTF-8 Support
$buf_pntr = nil
$works = true 
$c = 3.chr
$version = "2.0.1 Independent Alpha"
$author = "unn4m3d"
$home = Dir.chdir{|path| path} #Dirty hack!!! =)
require $home + "/.bot13/papi"
$bandits = {}
$plugins = {}
$userdata = ["Bot13_test","Bot13"]
$use_privmsgs = true
$msgs = {
	"lose" => ["LOL!", "Loser!", "Korean Random...", "I dunno why LOL", "Losers, losers everywhere", "kekeke"],
	"win"  => ["OMG OMG OMG","Congratulations! You are the WinRAR!!1","WHYYYY???"],
	"lvlup"=> ["LVL UP =^_^=", "Level up!", "- better than Cthulhu"],
	"bot13"=> ["Bot-th1rt3en #{$version} by #{$author}"],
	"join" => ["LOL, `U` has joined!", "`U` is the best thing ever"],
	"leave"=> ["Goodbye,`U`","All `U`'s base are belong to us!"],
}
$motd = "#MAPC is c00l!"
$conn = nil
$debug = []

def getmsg(m)
	return $msgs[m][Random.rand($msgs[m].size)]
end

class DebugMsg
	attr_accessor:msg,:level
	def initialize(m,l)
		@msg = m
		@level = l
	end
end

def debug_msg(level,message)
	$debug.push(DebugMsg.new(message,level))
end

def dfatal(msg)
	debug_msg(3,msg)
end

def dcritical(msg)
	debug_msg(2,msg)
end

def dwarning(msg)
	debug_msg(1,msg)
end

def dinfo(msg)
	debug_msg(0,msg)
end



#Bandit functions
def b_save()
	f = File.new($home + "/.bot13/bandit.cfg", "w")
	for k in $bandits.keys() 
		f.write(k.to_s + " " + $bandits[k].to_s + "\n") 
	end
	f.close()
end

def b_load()
	f = File.new($home + "/.bot13/bandit.cfg", "r")
	while not f.eof?
			s = f.gets()
			if s == nil or s == ""
				next
			end
			$bandits[s[0..1].to_i] = s[2..-1]
	end
	f.close()
end

def b_set(num, name)
	$bandits[num] = name
	b_save()
end

def b_show(chan)
	msg("Bandits:",chan)
	for k in $bandits.keys()
		msg((k.to_s)*3 + " - " + $bandits[k],chan)
	end
end

$perms = {}
class Permissions
	def self.set(nick,lvl)
		$perms[nick] = lvl
		self.save()
	end

	def self.load()
		f = File.open($home + "/.bot13/perms.cfg")
		while not f.eof?
			s = f.gets.split(" ")
			$perms[s[0]] = s[1].to_i
		end
		f.close
	end

	def self.save()
		if not $perms[".default"]
			$perms[".default"] = 0
		end
		f = File.open($home + "/.bot13/perms.cfg","w")
		for k in $perms.keys()
			f.write(k + " " + $perms[k].to_s + "\n") 
		end
		f.close
	end

	def self.set_default(lvl)
		self.set(".default",lvl)
	end

	def self.get(name)
		if $perms[name]
			return $perms[name]
		else
			return $perms[".default"]
		end
	end
end


#NickList is deprecated
$list = nil

#Function to say a message on a channel
#
#@param msg Message
#@param chan Channel

def msg(msg,chan)
	if chan == nil
		chan = $channels[0]
	end
	$conn.send_message(chan,msg)
end

def notice(msg,usr)
	$conn.send_notice(usr,msg)
end

#Base class for commands

class BotCommand
	#Basic constructor
	#
	#@param func Proc object to execute on call 
	#@param p Permission level to do that. Not implemented yet, please set to 0
	attr_accessor :permlvl,:func,:name,:timeout,:alias
	def set(func, p,name,t)
		@func = func
		@permlvl = p
		@name = name
		@timeout = t
	end
	
	#Basic entrypoint
	#
	#@param args Arguments
	#@param usr User that has sent the command
	#@param chan Channel where the command has been received 
	def execute(args,usr,chan)
		dinfo("[INFO] Executing cmd #{name} with args [#{args.join(",")}]")
		if $cmdt[@name][usr] != nil
			if $cmdt[@name][usr] + @timeout > Time.now
				notice("This command has timeout #{@timeout}s",usr)
				return
			end
		end
		if Permissions.get(usr) < @permlvl
			notice("You have not permissions. Required:#{@permlvl}. Available:#{Permissions.get(usr)}",usr)
			return
		end
		@func.call(args,usr,chan)
		$cmdt[@name][usr] = Time.now
	end
end

class HelpPage
	attr_accessor:brief,:text
	def initialize(b,t)
		@brief = b
		@text = t
	end
end

$cmds = {}
$cmdt = {}
$cmdh = {}
$rtab = {}

def addreact(regexps,func)
	for r in regexps
		$rtab[r] = func
	end
end

def addcmd(name,perm,cmd,timeout)
	$cmds[name] = BotCommand.new()
	$cmds[name].set(cmd,perm,name,timeout)
	$cmds[name].alias = nil
	$cmds.rehash
	$cmdt[name] = {}
end

def addalias(name,cmd)
	$cmds[name] = $cmds[cmd]
	$cmds[name].alias = cmd
	$cmds.rehash
	$cmdt[name] = {}
end


def is_valid_chan(chan)
	for c in $channels
		if chan == c
			return true
		end
	end
	if chan == $userdata[0] and $use_privmsgs == true then
		return true
	end
	return false
end

def addhelp(name,brief,help)
	$cmdh[name] =  HelpPage.new(brief,help)
end

def aliases(cmd)
	a = []
	for k in $cmds.keys
		if $cmds[k].alias == cmd
			a.push(k)
		end
	end
	return a
end

module LOCALE
	RUS = 0
	ENG = 1
end

class BotPlugin
	attr_accessor:name,:version,:author,:locale,:desc,:license
	def initialize(n,v,a,l,d,li)
		@name = n
		@version = v
		@author = a
		if l.class == "Integer"
			@locale = l
		else
			if l == "RUS"
				@locale = LOCALE::RUS
			else
				@locale = LOCALE::ENG
			end 
		end
		@desc = d
		@license = li
	end
	
	def older?(v)
		for i in (0...v.length)
			if i < @version.length
				if v[i].chr.to_i > @version[i].chr.to_i
					return true
				elsif v[i].chr.to_i < @version[i].chr.to_i
					return false
				end
			end
		end
		return false
	end
end

def register_plugin(n,v,a,l,d,li)
	$plugins.push(BotPlugin.new(n,v,a,l,d,li))
end

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
		puts "Hello\n"
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
		msg(">" + num[0].to_s + "--<",c)
		num[1] = Random.rand(10)
		msg(">" + num[0].to_s + num[1].to_s + "-<",c)
		num[2] = Random.rand(10)
		m = ">" + num.join + "<"
		if num[1] == num[0] and num[1] == num[2]
			m += " " + getmsg("win")
			b_set(num[0],u)
		else
			if num[1] != num[2] and num[1] != num[0] and num[0] != num[2]
					m += " " + getmsg("lose")
			else
				m += " Второй шанс"
				msg(m,c)
				if num[1] == num[2]
					num[0] = Random.rand(10)
				elsif num[0] == num[2]
					num[1] = Random.rand(10)
				elsif num[0] == num[1]
					num[2] = Random.rand(10)
				end
				m = ">" + num.join + "< "
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
	#papiinit	
end

weechat_init

$conn.start
