module Bot13
	
	class CmdEngine
		attr_accessor:cmds,:timer
		# Add command to list
		# @param [Bot13::Command] cmd Command
		def addcmd(cmd)
			@cmds[cmd.name.gsub(/^[\/!]/,'')] = cmd 
		end
	
		# Initialize engine
		# @note Erases command data and timer data
		def initialize
			@cmds = {}
			@timer = CmdTimer.new
		end
	
		# Get original command name
		# @param [String] cmd Command name
		# @return [String] Original command name or nil if command doesn't exist
		# @note Works recursively
		def get_original_name(cmd)
			return nil unless @cmds[cmd]
			return (@cmds[cmd].alias ? get_original_name(@cmds[cmd].alias) : cmd)
		end
	
		# Get aliases for command
		# @param [String] cmd Command name
		# @return [Array
		def get_aliases(cmd)
			cmd = get_original_name(cmd)
			a = [cmd]
			for k in @cmds.keys
				if get_original_name(k) == cmd then
					a.push k
				end
			end
			a
		end
	
		# Parse message
		# 
		# @param [String] msg Message
		# @return [Bot13::Command] Command or nil
		def parse(msg)
			msg._args ||= msg.text.sub(/^[^\s][\s@]/,'')
			if msg.text.match(/^[\/]/) then
				puts "[INFO] Command!"
				cmd = msg.text.gsub(/^[\/]([^\s\/!@]+)[\s@]?.*$/){$1}
				puts cmd
				if @cmds[cmd] then
					return @cmds[cmd]
				end
			end
			nil
		end
	end

	class CmdTimer
		attr_accessor:cmds
		# Returns true if command can be called by user
		#
		# @param [String] cmd Command
		# @param [Integer] user UserID
		# @return [Boolean] Whether command can be called
		def allow?(cmd,user)
			return (not (@cmds.has_key? cmd.to_s) or not (@cmds[cmd.to_s].has_key? user.to_s) or Time.now.to_i > @cmds[cmd.to_s][user.to_s].to_i)
		end
	
		# Set timeout for specified user and command
		#
		# @param [String] cmd Command name
		# @param [Integer] user User ID
		# @param [Integer] sec Timeout in seconds
		def set_timeout(cmd,sec,user)
			@cmds[cmd] ||= {}
			@cmds[cmd][user] = sec
		end	
		
		# Initialize data
		# @api private
		# @note Erases data on call
		def initialize
			@cmds = {}
		end
	end

	class Command
		attr_accessor:name,:alias,:proc,:perm
		def timeout(timer,key,sec,user)
			timer.set_timeout(key,sec,user)
		end
	
		# Call command
		# @yieldparam [CmdEngine] engine CmdEngine context
		# @yield [Command] Itself (to give command an ability to set timeout)
		# @yieldparam [TgAPI::Message] msg Message
		def call(engine,msg)
			@proc.call(engine,self,msg)
		end
		
		def initialize(n,pr,p,a=nil)
			@name,@proc,@perm,@alias = n,pr,p,a
		end
	end
	
end
