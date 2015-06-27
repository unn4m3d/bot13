=begin
	Bot13 v 1.7.1 Beta
	By S.Melnikov a.k.a. unn4m3d
	License : GNU GPLv3
	
	Changelog:
		v 1.7.1B(#10)
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
$channels = ["#th1rt3en"]
$server = "irc.ircnet.ru"
$buf_pntr = nil
$works = true 
$c = 3.chr
$version = "1.7.1 Beta"
$author = "unn4m3d"
$home = Dir.chdir{|path| path} #Dirty hack!!! =)
require $home + "/.bot13/papi"
$bandits = {}
$plugins = {}
$msgs = {
	"lose" => ["LOL!", "Loser!", "Korean Random...", "I dunno why LOL", "Losers, losers everywhere", "kekeke"],
	"win"  => ["OMG OMG OMG","Congratulations! You are the WinRAR!!1","WHYYYY???"],
	"lvlup"=> ["LVL UP =^_^=", "Level up!", "- better than Cthulhu"],
	"bot13"=> ["Bot-th1rt3en #{$version} by #{$author}"],
	"join" => ["LOL, `U` has joined!", "`U` is the best thing ever"]
}
$motd = "#MAPC is c00l!"

def getmsg(m)
	return $msgs[m][Random.rand($msgs[m].size)]
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

#Use only this to switch on/switch off bot
#
#@param s State to set
def setstate(s)
	if $works == false
		buf_pntr = Weechat.buffer_get_pointer(Weechat.current_buffer,"buf_pntr")
	end
	$works = s
	if $works
		Weechat.print("", "Bot is ready!")
	else
		Weechat.print("", "Shutting down...")
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


class NickList
	attr_accessor :pntr,:lpntr,:chan,:serv
	def update(s,c)
		p = "irc"
		name = "irc.#{s}.#{c}"
		@pntr = Weechat.buffer_search(p,name)
		@lpntr = Weechat.infolist_get("irc_nick","","#{s},#{c}")
		@chan = c
		@serv = s
	end
	def initialize(serv,chan)
		p = "irc"
		name = "irc.#{serv}.#{chan}"
		@pntr = Weechat.buffer_search(p,name)
		@lpntr = Weechat.infolist_get("irc_nick","","#{serv},#{chan}")
		@chan = chan
		@serv = serv
	end
	def list
		l = []
		p = Weechat.infolist_next(@lpntr)
		while p and p != "" and p != 0
			l.push(Weechat.infolist_string(@lpntr, "name"))
			p = Weechat.infolist_next(@lpntr)
			Weechat.print("", "p is #{p}")
		end
		Weechat.infolist_reset_item_cursor(@lpntr)
		return l
	end
	def search(nick)
		r = Weechat.nicklist_search_nick(@pntr,"",nick)
		if r == ""
			return false
		else
			return true
		end
	end
end
$list = nil
#String works
class RMessage
	attr_accessor:nick,:user,:host,:cmd,:msg,:chan
	def parse(inmsg)
		#Parses IRC message like :nick!user@host cmd :msg
		@nick = inmsg.sub(/^:([^!]+)!.+$/){$1}
		@msg = inmsg.sub(/^:[^:]+:/, "")
		@chan = inmsg.sub(/^:[^:#]+(#.+)\ :.*$/){$1}
		@user = inmsg.sub(/^:[^!]+!(.+)@.+\ :.*$/){$1}
		Weechat.print("", "Parsed message : " + @msg + " from " + @nick + "(" + @user + ") on " + @chan + ".")
	end
end

class JMessage < RMessage
	def parse(inmsg)
		super(inmsg)
		@chan = inmsg.sub(/:[^:#]+:(#.+)/){$1}
		Weechat.print("",@nick + "(" + @user + ") has joined " + @chan)
	end
end
#End of string works

#Function to say a message on a channel
#
#@param msg Message
#@param chan Channel

def msg(msg,chan)
	if chan == nil
		chan = $channels[0]
	end
	Weechat.command($buf_pntr, "/msg " + chan + " " + msg)
end

def notice(msg,usr)
	Weechat.command($buf_pntr,"/notice " + usr + " " + msg)
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
		if $cmdt[@name][usr] != nil
			if $cmdt[@name][usr] + @timeout > Time.now
				Weechat.command($buf_pntr,"/notice #{usr} This command has timeout #{@timeout}s")
				return
			end
		end
		if Permissions.get(usr) < @permlvl
			Weechat.command($buf_pntr,"/notice #{usr} You have not permissions. Required:#{@permlvl}. Available:#{Permissions.get(usr)}")
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

def admcb(data,buffer,args)
	if args == "on"
		setstate(true)
	elsif args == "off"
		setstate(false)
	end
	Weechat.print($buf_pntr, "DBOT")
	return Weechat::WEECHAT_RC_OK
end

def is_valid_chan(chan)
	for c in $channels
		if chan == c
			return true
		end
	end
	return false
end

def comcb(data,signal,sdata)
	Weechat.print("","Received SDATA : " + sdata)
	if not $works
		return Weechat::WEECHAT_RC_OK
	end
	pmsg = RMessage.new()
	pmsg.parse(sdata)
	if not is_valid_chan(pmsg.chan) then
		return Weechat::WEECHAT_RC_OK
	end
	for k in $cmds.keys()
		if (pmsg.msg + " ")[0...k.length+1] == k + " "   
			s = "Executing cmd " + k + " with args "
			sp = []
			if pmsg.msg[k.length+2] != nil
				sp = pmsg.msg[k.length+1..-1].split(" ")
			end
			for e in sp
				s += "'"
				s += e
				s += "', "
			end
			Weechat.print("",s)
			$cmds[k].execute(pmsg.msg.split(" ")[1..-1],pmsg.nick,pmsg.chan)
			break
		end
	end
	for r in $rtab.keys
		if pmsg.msg.match(r)
			$rtab[r].call(pmsg.user,pmsg.chan,pmsg.msg)
		end
	end
	return Weechat::WEECHAT_RC_OK
end

def motdcb(data,buffer,args)
	$motd = args
end

def joincb(data,signal,sdata)
	if $works
		Weechat.print("","Received SDATA : " + sdata)
		pmsg = JMessage.new
		pmsg.parse(sdata)
		if not is_valid_chan(pmsg.chan)
			return Weechat::WEECHAT_RC_OK
		end
		msg(getmsg("join").gsub(/`U`/,pmsg.nick),pmsg.chan)
	end
	return Weechat::WEECHAT_RC_OK	
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

def weechat_init
	Weechat.register("Bot13", $author,$version, "GNU GPLv3", "Simple bot","","cp-1251")
	$buf_pntr = Weechat.buffer_get_pointer(Weechat.current_buffer,"buf_pntr")
	#Hooks
	ch = Weechat.hook_command("dbot", "","","","","admcb","") #Command hook
	ch = Weechat.hook_command("sbm", "","","","","motdcb","") #Command hook
	sh = Weechat.hook_signal("*,irc_in2_privmsg", "comcb","")
	Weechat.hook_signal("*,irc_in2_join","joincb","")
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
				Weechat.command($buf_pntr,"/notice #{u} You have level #{$perms[u].to_s}")
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
	$list = NickList.new($server,$channel)
	papiinit
	Weechat.command($buf_pntr,"/me " + getmsg("lvlup"))
end
