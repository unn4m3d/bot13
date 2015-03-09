=begin
	Bot13 v 1.6 Beta
	By S.Melnikov a.k.a. unn4m3d
	License : GNU GPLv3
	
	Changelog:
		v 1.6B(#6)
		>Added PluginAPI
		
		v 1.5B(#5)
		>Added permissions
		>Every command has its own timeout
		>Now can only execute commands at one channel (Will be fixed in 1.6)
	
		v 1.4A(#4)
		>Added !help command
		>Upgraded !motd command
		>Messages when user joins
		>Upgraded parser (Now you can use e.g. !lol and !lold, and it can be different commands)
		>Now bot can be switched off
		
		v 1.3A(#3)
		>Random messages
		>Added !motd command
		>Added /sbm command (Sets motd)
		>Timeout between commands
		>Refactored some lines
		>Fixed a bug with table of records
		
		v 1.2A(#2)
		>New bandit algorythm!
		>Fixed a bug in a cmd params  (that passed username instead of nick)
		
		v 1.1A(#1)
		>Added !bandit and !winners cmds
		>Added !random command
		>Added !cmds command
		>Fixed bugs
		>Upgraded parser (Now parses channel name, and reads correctly #,!,: symbols)
		
		v 1.0A(#0)
		>First release
=end

#Environment vars
$channel = "#th1rt3en"
$buf_pntr = nil
$works = false
$version = "1.6 Beta"
$author = "unn4m3d"
$home = Dir.chdir{|path| path} #Dirty hack!!! =)
require $home + "/.bot13/papi"
$bandits = {}
$msgs = {
	"lose" => ["LOL!", "Loser!", "Korean Random...", "I dunno why LOL", "Losers, losers everywhere", "kekeke"],
	"win"  => ["You're the great master!","Congratulations! You are the WinRAR!!1","WHYYYY???"],
	"lvlup"=> ["LVL UP =^_^=", "Level up!", "is the greatest script in the world"],
	"bot13"=> ["Bot-th1rt3en #{$version} by #{$author}", "I am the greatest bot!"],
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
		f.write(k.to_s + " " + $bandits[k].to_s) 
	end
	f.close()
end

def b_load()
	f = File.new($home + "/.bot13/bandit.cfg", "r")
	while not f.eof?
			s = f.gets()
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
		chan = $channel
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
	attr_accessor :permlvl
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
				Weechat.command($buf_pntr,"/notice #{usr} This command has #{@timeout} seconds timeout")
				return
			end
		end
		if Permissions.get(usr) < @permlvl
			Weechat.command($buf_pntr,"/notice #{usr} You have not permission to call this")
			return
		end
		@func.call(args,usr,chan)
		$cmdt[@name][usr] = Time.now
	end
end

$cmds = {}
$cmdt = {}
$timeout = 150

def addcmd(name,perm,cmd,timeout)
	$cmds[name] = BotCommand.new()
	$cmds[name].set(cmd,perm,name,timeout)
	$cmds.rehash
	$cmdt[name] = {}
end

def addalias(name,cmd)
	$cmds[name] = cmds[cmd]
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

def isvc?(chan)
	for v in $channels
		if v == chan
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
	if $channel != pmsg.chan then
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
		msg(getmsg("join").gsub(/`U`/,pmsg.nick),pmsg.chan)
	end
	return Weechat::WEECHAT_RC_OK
end

def weechat_init
	Weechat.register("Bot13", $author,$version, "GNU GPLv3", "A simple bot written in ruby","","cp-1251")
	$buf_pntr = Weechat.buffer_get_pointer(Weechat.current_buffer,"buf_pntr")
	#Hooks
	ch = Weechat.hook_command("dbot", "","","","","admcb","") #Command hook
	ch = Weechat.hook_command("sbm", "","","","","motdcb","") #Command hook
	sh = Weechat.hook_signal("*,irc_in2_privmsg", "comcb","")
	Weechat.hook_signal("*,irc_in2_join","joincb","")
	addcmd("!bot13",0,Proc.new{
		|a,u,c| msg("Bot-Th1rt3en v" + $version + " by " + $author, c)
	},10)
	$cmds.rehash()
	addcmd("!cmds",0,Proc.new{
		|a,u,c|
		for k in $cmds.keys()
			msg(k,c)
		end
	},20)
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
	addcmd("!bandit", 0, Proc.new{
		|a,u,c|
		num = []
		num[0] = Random.rand(10)
		msg(">" + num[0].to_s + "--<",c)
		num[1] = Random.rand(10)
		while num[1] != num[0] and Random.rand(10) < 5
			num[1] = Random.rand(10)
		end
		msg(">" + num[0].to_s + num[1].to_s + "-<",c)
		num[2] = Random.rand(10)
		m = ">" + num[0].to_s + num[1].to_s + num[2].to_s + "<"
		if num[2] != num[1]
			if num[1] != num[0]
				m += getmsg("lose")
			else
				m += " Second chance"
				msg(m,c)
				num[2] = Random.rand(10)
				m = ">" + num[0].to_s + num[1].to_s + num[2].to_s + "<"
				if num[0] == num[1] and num[1] == num[2]
					m += getmsg("win") + " Type !winners to watch winners!"
					b_set(num[0],u)
				else
					m += getmsg("lose")
				end
			end
		elsif num[1] == num[0]
			m += getmsg("win") + " Type !winners to watch winners!"
			b_set(num[0],u)
		else
			m += getmsg("lose")
		end
		msg(m,c)
		
	},60)
		
	addcmd("!winners", 0, Proc.new{
		|a,u,c|
		b_show(c)
	},10)
		
	addcmd("!motd", 0, Proc.new{
		|a,u,c|
		if a.length > 0
			$motd = a.join(" ")
		else
			msg($motd,c)
		end
	},10)
	addcmd("!help", 0, Proc.new{
		|a,u,c|
		msg("=============HELP=============",c)
		msg("!random - random 0 to 9",c)
		msg("!random x - random 0 to x", c)
		msg("!random x y - random x to y", c)
		msg("!bot13 - bot version",c)
		msg("!cmds - list commands",c)
		msg("!bandit - play bandit",c)
		msg("!winners - watch bandits",c)
		msg("!motd - show MOTD",c)
		msg("!motd m - set MOTD m", c)
		msg("==============================",c)
	},60)
		
	addcmd("!perm", 5, Proc.new{
		|a,u,c|
		if a.length == 1 
			if a[0] == "get"
				Weechat.command($buf_pntr,"/notice #{u} You have level #{$perms[u].to_s}")
			elsif a[0] == "show"
				for k in $perms.keys()
					msg(k + " " + $perms[k].to_s,c)
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
	if not Dir.exists?($home + "/.bot13/")
		Dir.mkdir($home + "/.bot13/")
	end
	if not File.exists?($home + "/.bot13/bandit.cfg")
		b_save()
	end
	if not File.exists?($home + "/.bot13/perms.cfg")
		p_save()
	end
	b_load()
	Permissions.load()
	if not Dir.exists?($home + "/.bot13/plugins/")
		Dir.mkdir($home + "/.bot13/plugins")
	end
	papiinit
	Weechat.command($buf_pntr,"/me " + getmsg("lvlup"))
end