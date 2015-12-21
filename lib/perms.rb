module Bot13
		
	class Perms
		@@users = {}
		attr_accessor:global,:chats
		def self.load
			j = JSON.parse File.read File.join($home,'data/permissions.json')
			for u in j['users'] do
				@@users.push Perms.new u
			end
		end
	
		def self.save
			j = {'users'=>[]}
			for u in @@users do
				j['users'].push({'global'=>u.global, 'chats'=>u.chats})
			end
			File.open(File.join($home,'data/permissions.json'),'w') do |f| f.write JSON.generate j end
		end
	
		def get(chat)
			if @chats[chat.to_s] then
				return (@chats[chat.to_s].to_i > @global ? @chats[chat.to_s] : @global)
			else
				return @global
			end
		end
	
		def initialize(j)
			@global = j['global']
			@chats = j['chats']
		end
	
		def self.get(user,cid=-1)
			if @@users[user.to_s] then
				return @@users[user.to_s].get(cid).to_i
			else
				if user == ".default" then
					return 0
				else
					self.get ".default", cid
				end
			end
		end
	
		def self.set(user,cid,lvl)
			@@users[user.to_s] ||= Perms.new(self.get('.default'),self.get('.default'))
			@@users[user.to_s].chats[cid.to_s] = lvl
		end
	
		def self.set_g(user,lvl)
			@@users[user.to_s] ||= Perms.new(self.get('.default'),self.get('.default'))
			@@users[user.to_s].global = lvl
		end
	end

	class ChanPerms
		@@channels = {}
		def self.allow?(perm,chan)
			if @@channels[chan.to_s] then
				return @@channels[chan.to_s].has_value? perm.to_s
			else
				return true
			end
		end
		
		def self.save
			File.open(File.join($home,'data/channels.json'),'w'){|f|
					f.write JSON.generate @@channels
			}
		end	
		
		def self.load
			@@channels = JSON.parse File.read File.join($home,'data/channels.json')
		end
	end
	
end
