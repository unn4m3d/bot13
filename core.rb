=begin
	Bot13 v 1.2 Alpha
	By S.Melnikov a.k.a. unn4m3d
	License : GNU GPLv3
	
	Changelog:
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
$channel = "#th1rt3en" #Default channel
$buf_pntr = nil
$works = false
$version = "1.2 Alpha"
$author = "unn4m3d"
$home = Dir.chdir{|path| path} #Dirty hack!!! =)
$bandits = {}

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

#String works
class RMessage
	attr_accessor:nick,:user,:host,:cmd,:msg,:chan
	def parse(inmsg)
		#Parses IRC message like :nick!user@host cmd :msg
		@nick = inmsg.sub(/^:([^!]+)!.+$/){$1}
		@msg = inmsg.sub(/^:[^:]+:/, "")
		@chan = inmsg.sub(/^:[^:#]+(#.+)\ :.*$/){$1}
		@user = inmsg.sub(/^:[^!]+!(.+)@.+\ :.*$/){$1}
		Weechat.print("", "Parsed message : " + @msg + " from " + @nick + "(" + @user + ") on " + @chan)
	end
end

def strstt(str,pat)
	if str[0..pat.length] == pat
		return true
	else
		return false
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

#Base class for commands

class BotCommand
	#Basic constructor
	#
	#@param func Proc object to execute on call 
	#@param p Permission level to do that. Not implemented yet, please set to 0
	attr_reader :permlvl
	attr_writer :permlvl
	def set(func, p)
		@func = func
		@permlvl = p
	end
	
	#Basic entrypoint
	#
	#@param args Arguments
	#@param usr User that has sent the command
	#@param chan Channel where the command has been received 
	def execute(args,usr,chan)
		@func.call(args,usr,chan)
	end
end

$cmds = nil

def addcmd(name,perm,cmd)
	$cmds[name] = BotCommand.new()
	$cmds[name].set(cmd,perm)
	$cmds.rehash
end

def addalias(name,cmd)
	$cmds[name] = cmds[cmd]
	$cmds.rehash
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


def comcb(data,signal,sdata)
	Weechat.print("","Received SDATA : " + sdata)
	#if not $works
	#	return Weechat::WEECHAT_RC_OK
	#end
	pmsg = RMessage.new()
	pmsg.parse(sdata)
	for k in $cmds.keys()
		if pmsg.msg[0...k.length] == k
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

def weechat_init
	Weechat.register("Bot13", $author,$version, "GNU GPLv3", "A simple bot written in ruby","","cp-1251")
	$buf_pntr = Weechat.buffer_get_pointer(Weechat.current_buffer,"buf_pntr")
	#Hooks
	ch = Weechat.hook_command("dbot", "","","","","admcb","") #Command hook
	sh = Weechat.hook_signal("*,irc_in2_privmsg", "comcb","")
	$cmds = {"!bot13" => BotCommand.new()}
	$cmds["!bot13"].set(Proc.new{
		|a,u,c| msg("Bot-Th1rt3en v" + $version + " by " + $author, c)
	},0)
	$cmds.rehash()
	addcmd("!cmds",0,Proc.new{
		|a,u,c|
		for k in $cmds.keys()
			msg(k,c)
		end
	})
	addcmd("!random", 0, Proc.new{
		|a,u,c|
		if a.length == 0
			msg(Random.rand(10).to_s, c)
		elsif a.length == 1
			msg(Random.rand(Integer(a[0])).to_s,c)
		else
			msg((Integer(a[0])+ Random.rand(Integer(a[1]) - Integer(a[0]))).to_s,c)
		end
	})
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
				m += "Loser"
			else
				m += " Second chance"
				num[2] = Random.rand(10)
				m = ">" + num[0].to_s + num[1].to_s + num[2].to_s + "<"
				if num[0] == num[1] and num[1] == num[2]
					m += " You won! Type !winners to watch winners!"
					b_set(num[0],u)
				else
					m += " Loser!"
				end
			end
		elsif num[1] == num[0]
			m += " You won! Type !winners to watch winners!"
			b_set(num[0],u)
		else
			m += " Loser!"
		end
		msg(m,c)
		
	})
		
	addcmd("!winners", 0, Proc.new{
		|a,u,c|
		b_show(c)
	})
	if not Dir.exists?($home + "/.bot13/")
		Dir.mkdir($home + "/.bot13/")
	end
	if not File.exists?($home + "/.bot13/bandit.cfg")
		b_save()
	end
	b_load()
	Weechat.command($buf_pntr,"/me LVL UP =^_^=")
end