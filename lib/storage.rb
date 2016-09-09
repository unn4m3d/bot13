class Hash
	def flatten_r
		def f(ha,path="")
			if ha.kind_of? Hash then
				a = {}
				ha.each{
					|k,v|
					if v.kind_of? Array or v.kind_of? Hash
						a.merge! f(v,path+k+".")
					else
						a[k] = v.to_s
					end
				}
				return a
			elsif ha.kind_of? Array then
				a = {}
				ha.each_with_index{
					|e,i|
					a[i.to_s] = e
				}
				return f(a,path)
			else
				raise Exception.new "Element must be an array or a hash"
			end
		end
		f(self)
	end

	def deepset(path,value)
		key = path.shift
		if path.length <= 0 then
			self[key] = value
		else
			self[key] = {} unless self[key].is_a? Hash
			self[key].deepset(value,path)
		end
	end
end

module Bot13::Storage
	NI_EXCEPTION = Exception.new("Not implemented")
	NP_EXCEPTION = Exception.new("Not permitted")

	class StorageDriver

		def save(data)
			raise NI_EXCEPTION
		end

		def load
			raise NI_EXCEPTION
		end

		def open
			raise NI_EXCEPTION
		end

		def close
			raise NI_EXCEPTION
		end

		def partial_sync(diff)
			raise(partial_syncable? ? NI_EXCEPTION : NP_EXCEPTION)
		end

		def partial_syncable?
			false
		end
	end

	class JSONStorageDriver < StorageDriver
		attr_reader:filename,:file,:mutex

		def save(data)
			@mutex.synchronize do
				@file.truncate(0)
				@file.pos = 0
				@file.write JSON.generate data
				@file.fdatasync
			end
		end

		def load(storage=nil)
			data = nil
			@mutex.synchronize do
				data = JSON.parse @file.read
			end
		end

		def initialize(bot,*params)
			@mutex = Mutex.new
			@filename = File.join(bot.home,params.first)
		end

		def open
			@file = File.open @filename
		end

		def close
			@file.close
		end
	end

	class Storage
		attr_reader:driver,:data
		def set(key,value,do_not_sync=false)
			path = key.split(".")
			@data.deepset(path,value)
			save key => value unless do_not_sync
		end

		def get(key)
			@data.dig(*key.split("."))
		end

		def save(changes=nil)
			(@driver.partial_syncability? and changes) ? (@driver.partial_sync changes) : (@driver.save @data)
		end

		def load
			@driver.open
			d = @driver.load self
			@data = d if d
		end

		def initialize(driver)
			@driver = driver
		end

		def close
			@driver.close
		end
	end


	class SyncStorage < Storage
		attr_reader:mutex
		def set(k,v,d=false)
			@mutex.synchronize{super k,v,d}
		end

		def get(k)
			@mutex.synchronize{super k}
		end

		def load
			@mutex.synchronize{super}
		end

		def initialize(d)
			@mutex = Mutex.new
			super d
		end

	end
end
