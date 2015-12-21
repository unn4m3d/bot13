module Bot13
	
	class CmdEngine
		attr_accessor:cmds,:timer
		def addcmd(cmd)
			@cmds[cmd.name.gsub(/^[\/!]/,'')] = cmd 
		end
	
		def initialize
			@cmds = {}
			@timer = CmdTimer.new
		end
	
		def get_original_name(cmd)
			return nil unless @cmds[cmd]
			return (@cmds[cmd].alias ? get_original_name(@cmds[cmd].alias) : cmd)
		end
	
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
		def allow?(cmd,user)
			return (not (@cmds.has_key? cmd.to_s) or not (@cmds[cmd.to_s].has_key? user.to_s) or Time.now.to_i > @cmds[cmd.to_s][user.to_s].to_i)
		end
	
		def set_timeout(cmd,sec,user)
			@cmds[cmd] ||= {}
			@cmds[cmd][user] = sec
		end	
		
		def initialize
			@cmds = {}
		end
	end

	class Command
		attr_accessor:name,:alias,:proc,:perm
		def timeout(timer,key,sec,user)
			timer.set_timeout(key,sec,user)
		end
	
		def call(engine,msg)
			@proc.call(engine,self,msg)
		end
		
		def initialize(n,pr,p,a=nil)
			@name,@proc,@perm,@alias = n,pr,p,a
		end
	end
	
end
