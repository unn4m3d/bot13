=begin
	API for Bot13 2.0.2+ Independent Alpha
=end
#@author unn4m3d

$c = 3.chr
$version = "2.0.2 Independent Alpha"
$author = "unn4m3d"
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



#Saves bandit's records
def b_save
	f = File.new($home + "/.bot13/bandit.cfg", "w")
	for k in $bandits.keys() 
		f.write(k.to_s + " " + $bandits[k].to_s + "\n") 
	end
	f.close
end

#Loads bandit's records
def b_load
	f = File.new($home + "/.bot13/bandit.cfg", "r")
	while not f.eof?
			s = f.gets
			if s == nil or s == ""
				next
			end
			$bandits[s[0..1].to_i] = s[2..-1]
	end
	f.close
end

#Sets bandit's record and automatically saves it
#
#@param num [Integer] Number 0-9 (000-999)
#@param name [String] Player's name
#@note This uses #{b_save}
def b_set(num, name)
	$bandits[num] = name
	b_save
end

#Shows bandit's records
#
#@param chan [String] Target (channel or user's nick)
def b_show(chan)
	msg("Bandits:",chan)
	for k in $bandits.keys()
		msg((k.to_s)*3 + " - " + $bandits[k],chan)
	end
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

#NickList
#@note Compatible with v 1.6.2B
class NickList
	attr_accessor:chan,:serv
	#Main constructor
	#
	#@param s [String] Channel name if c is nil, else server name
	#@param c [String] Optional channel name
	def initialize(s,c=nil)
		unless c
			@chan = c
			@serv = s
		else
			@chan = s
			@serv = nil
		end
		return unless $conn
		for k in $conn.channels
			if k.name == @chan then
				@cdata = k
			end
		end
		@cdata = nil
	end
	#Alias for {#initialize}
	def update(s,c=nil)
		initialize(s,c)
	end
	#Lists users
	#
	#@return [Array] Users' nicks
	def list
		IRCConnection.send_to_server("NAMES #{@chan}")
		while not $udata
		end
		l,$udata =  $udata.split(" "),nil
		return l
	end
	#Searches for user
	#
	#@param nick [String] User's nick
	#@return [Boolean] true if user exists on channel, else false
	def search(nick)
		for u in list
			if u == nick or u == nick.gsub(/[@%+]/,'') then
				return true
			end
		end
		return false
	end
end
#NickList instance
#@deprecated It has to be refactored, and will be deleted to 2.1
$list = NickList.new($server,$channels[0])

#Userdata reply
$udata = nil

#Sends a message on a channel
#
#@param msg [String] Message
#@param chan [String] Channel
def msg(msg,chan=$channels[0])
	$conn.send_message(chan,msg)
end

#Sends a notice to a target
#
#@param msg [String] Message
#@param usr [String] Target
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

#HelpPage class
class HelpPage
	attr_accessor:brief,:text
	#Constructor
	#
	#@param b [String] Brief (short description)
	#@param t [Array<String>] Description. One String per line
	def initialize(b,t)
		@brief = b
		@text = t
	end
end

#Commands
$cmds = {}
#Timer data
$cmdt = {}
#Help
$cmdh = {}
#Reactions
#@deprecated Will be refactored to 2.1
$rtab = {}

#Adds Reaction
#
#@param regexps [Array<Regexp>] Regexps to match
#@param func [Proc] Process to execute
#@deprecated Will be refactored to 2.1
def addreact(regexps,func)
	for r in regexps
		$rtab[r] = func
	end
end

#Adds command
#
#@param name [String] Command name
#@param perm [Integer] Required permlvl
#@param cmd [Proc] Process to execute
#@param timeout [Fixnum] Timeout in seconds between usage
def addcmd(name,perm,cmd,timeout)
	$cmds[name] = BotCommand.new()
	$cmds[name].set(cmd,perm,name,timeout)
	$cmds[name].alias = nil
	$cmds.rehash
	$cmdt[name] = {}
end

#Adds alias
#
#@param name [String] Alias name
#@param cmd [String] Cmd name
def addalias(name,cmd)
	$cmds[name] = $cmds[cmd]
	$cmds[name].alias = cmd
	$cmds.rehash
	$cmdt[name] = {}
end

#Must we work on this channel?
#
#@param chan [String] Channel
#@return [Boolean] true or false
#@api private
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

#Adds help page
#
#@param name [String] Page name
#@param brief [String] Brief
#@param help [Array<String>] Desc
def addhelp(name,brief,help)
	$cmdh[name] =  HelpPage.new(brief,help)
end

#Aliases for command
#
#@param cmd [String] Command name
#@return [Array<String>] Aliases for this command
def aliases(cmd)
	a = []
	for k in $cmds.keys
		if $cmds[k].alias == cmd
			a.push(k)
		end
	end
	return a
end

#Locales
#@deprecated Useless
module LOCALE
	RUS = 0
	ENG = 1
end

#Plugin info
class BotPlugin
	attr_accessor:name,:version,:author,:locale,:desc,:license
	#Constructor
	#
	#@param n [String] Name
	#@param v [String] Version
	#@param a [String] Author
	#@param l [String,Integer] Locale
	#@param d [String] Description
	#@param li [String] License
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
	
	#Is version older than v?
	#
	#@param v [Array] Version to compare
	#@return [Boolean] result
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

#@see {BotPlugin.initialize}
def register_plugin(n,v,a,l,d,li)
	$plugins.push(BotPlugin.new(n,v,a,l,d,li))
end
