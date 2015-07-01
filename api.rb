=begin
	API for Bot13 3.* Telegram Edition
=end
#@author unn4m3d

#$c = 3.chr
$version = "3.0 Telegram Edition Alpha"
$author = "unn4m3d"
require $home + "/.bot13/papi"
$msgs = {
	"lose" => ["LOL!", "Loser!", "Korean Random...", "I dunno why LOL", "Losers, losers everywhere", "kekeke"],
	"win"  => ["OMG OMG OMG","Congratulations! You are the WinRAR!!1","WHYYYY???"],
	"lvlup"=> ["LVL UP =^_^=", "Level up!", "- better than Cthulhu"],
	"bot13"=> ["Bot-th1rt3en #{$version} by #{$author}"],
	"join" => ["LOL, `U` has joined!", "`U` is the best thing ever"],
	"leave"=> ["Goodbye,`U`","All `U`'s base are belong to us!"],
}
$motd = "#MAPC is c00l!"
$debug = []
$bot = nil

def notice(m,u)
	$bot.sendMessage(u.to_i,m)
end

def msg(m,c)
	$bot.sendMessage(c.to_i,m)
end

#Gets random message from $msgs
#
#@param m [String] Type of message to get
#@return [String] Message
def getmsg(m)
	return $msgs[m][Random.rand($msgs[m].size)]
end

#Class representing the debug message.
#Contains message and its level (INFO/WARNING/CRITICAL/FATAL)
class DebugMsg
	attr_accessor:msg,:level
	#Main constructor
	#
	#@param m [String] Message
	#@param l [Integer] Level
	def initialize(m,l)
		@msg = m
		@level = l
	end
end

#Pushes the debug message in a stack
#
#@param level [Integer] Level
#@param message [String] Message
def debug_msg(level,message)
	$debug.push(DebugMsg.new(message,level))
end

#An alias for {#debug_msg}(3,msg). Pushes message with level 3 (FATAL)
#
#@param msg [String] Message
def dfatal(msg)
	debug_msg(3,msg)
end

#An alias for {#debug_msg}(2,msg). Pushes message with level 2 (CRITICAL)
#
#@param msg [String] Message
def dcritical(msg)
	debug_msg(2,msg)
end

#An alias for {#debug_msg}(1,msg). Pushes message with level 1 (WARNING)
#
#@param msg [String] Message
def dwarning(msg)
	debug_msg(1,msg)
end

#An alias for {#debug_msg}(0,msg). Pushes message with level 0 (INFO)
#
#@param msg [String] Message
def dinfo(msg)
	debug_msg(0,msg)
end

#Permissions database
$perms = {}

#Permissions
class Permissions
	#Sets permissions level
	#
	#@param nick [String] Target
	#@param lvl [Integer] Perm level
	#@note Calls {.save}
	def self.set(nick,lvl)
		$perms[nick] = lvl
		self.save()
	end

	#Loads permissions from a config
	def self.load
		f = File.open($home + "/.bot13/perms.cfg")
		while not f.eof?
			s = f.gets.split(" ")
			$perms[s[0]] = s[1].to_i
		end
		f.close
	end
	
	#Saves permissions to a config
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

	#Alias for {.set}(".default",lvl)
	def self.set_default(lvl)
		self.set(".default",lvl)
	end

	#Gets perm level
	#
	#@param name [String] User's nick
	#@return [String] User's permlvl
	def self.get(name)
		if $perms[name]
			return $perms[name]
		else
			return $perms[".default"]
		end
	end
end

$cmds = {}

def addcmd(n,p,f,t=0)
	$cmds[n] = (BotCommand.new(p,n,f))
end

class BotCommand
	attr_reader:perm,:name,:func
	def initialize(p,n,f)
		@perm = p
		@name = n
		@func = f
	end
	def execute(a,m)
		if Permissions.get(m.source["from"]["username"]) >= @perm
			@func.call(a,m)
		end
	end
end
