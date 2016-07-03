module Bot13
	Perms = Struct.new(:global,:local) do
		def to_hash
			return {"global"=>@global,"local"=>@local}
		end

		def calc
			(@global && @local ? (@global > @local ? @global : @local) : @global || @local || 0)
		end

		def self.from_hash(h)
			Perms.new(global:h['global'],local:h['local'])
		end
	end

	class PermEngine
		attr_accessor:data,:driver
		def save
			@driver.save @data
		end

		def load
			@data = @driver.load
		end

		def initialize(driver)
			@driver = driver
			@driver.open
		end

		def close
			@driver.close
		end

		def calc(uid)
			@data ||= {}
			@data['users'] ||= {}
			@data['users'][uid.to_s] || 0
		end

		def allow?(uid,cid,permlvl,permname)
			@data ||= {}
			@data['channels'] ||= {}
			calc(uid) >= permlvl and (not @data['channels'][cid.to_s] or (!permname) or @data['channels'][cid.to_s].include?(permname))
		end
	end

	stlib =  File.expand_path("../storage",__FILE__)
	require stlib
	class JSONPermDriver < Bot13::Storage::JSONStorageDriver

	end

end
