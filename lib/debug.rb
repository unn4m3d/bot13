module Bot13
	class DbgMsg
		attr_accessor:level,:info
		def initialize(i,l=MsgLevel::NONE)
			@level,@info = l,i
		end
	
		private
		def label
			case @level
				when MsgLevel::INFO
					"[INFO]"
				when MsgLevel::WARNING
					"[WARNING]"
				when MsgLevel::CRITICAL
					"[CRITICAL]"
				when MsgLevel::NONE
					""
				else
					"[FATAL]"
			end
		end
		public	
		def puts
			super "#{label} #{info}"
		end
	end

	class Debug
		@@messages = []
		def self.add(m)
			@@messages.push m
		end
	
		def puts(min_level = MsgLevel::NONE, cnt=-1)
			i = 0
			while i < @@messages.size and (cnt == -1 ? true : i < cnt) do
				@@messages[i].puts
				i+=1
			end
		end
	end

	module MsgLevel
		NONE 	= 0
		INFO 	= 1
		WARNING = 2
		CRITICAL= 3
		FATAL	= 4
	end
end

def lib(name,ex=true)
	begin
		require File.join($home,name)
	rescue => e
		puts "[FATAL] Can't load #{name}"
		puts e.backtrace
	end
end

def debug_msg(m,l=Bot13::MsgLevel::NONE)
	d = Bot13::DbgMsg.new(m,l)
	if not $options or not $options[:d] or $options[:d] <= l.to_i then
		d.puts
	end
	Bot13::Debug.add d
end

def dinfo(m)
	debug_msg(m,Bot13::MsgLevel::INFO)
end

def dwarning(m)
	debug_msg(m,Bot13::MsgLevel::WARNING)
end

def dcritical(m)
	debug_msg(m,Bot13::MsgLevel::CRITICAL)
end

def dfatal(m)
	debug_msg(m,Bot13::MsgLevel::FATAL)
end
