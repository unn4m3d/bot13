require 'mysql2'

module Bot13::Storage

	class MySQLStorageDriver < StorageDriver
		attr_accessor:connection,:dbparams
		def partial_syncable?
			true
		end

		def query(q)
			@connection.query q
		end

		def esc(e)
			@connection.escape e
		end

		def load(storage)
			res = query "SELECT dbkey,dbvalue FROM #{@dbparams['prefix']}_data"
			res.each{|row| storage.set(row['dbkey'],row['dbvalue'],true)}
			return nil
		end

		def save(data)
			newd = data.flatten_r
			newd.each{
				|k,v|
				if v != nil
					query "INSERT INTO #{@dbparams['prefix']}_data (dbkey,dbvalue) VALUES('#{esc k}','#{esc v}') ON DUPLICATE KEY UPDATE dbkey='#{esc v}'"
				end
			}
		end

		def partial_sync(diff)
			save diff
		end

		def initialize(*params)
			@dbparams = params
		end

		def open
			@connection = Mysql2::Client.new(@dbparams[:db])
		end

		def close
			@connection.close
		end
	end

	class MySQLPermDriver < MySQLStorageDriver
		def save data
			data['users'].each do |k,v|
				query "INSERT INTO #{@dbparams['prefix']}_global_perms (uid,level) VALUES(#{k.to_i},#{v.global.to_i}) ON DUPLICATE KEY UPDATE level=#{v.global.to_i}"
				v.local.each do |_k,_v|
					query "INSERT INTO #{@dbparams['prefix']}_local_perms (ucid,level) VALUES('#{k.to_i}_#{_k.to_i}',#{_v.to_i}) ON DUPLICATE KEY UPDATE level=#{_v.to_i}"
				end
			end
			data['channels'].each do |k,v|
				query "INSERT INTO #{@dbparams['prefix']}_channel_perms (cid,perms) VALUES(#{k.to_i},'#{esc v.join ";"}') ON DUPLICATE KEY UPDATE perms='#{esc v.join ";"}'"
			end
		end

		def load
			gresult = query "SELECT uid,level FROM #{@dbparams['prefix']}_global_perms"
			lresult = query "SELECT ucid,level FROM #{@dbparams['prefix']}_local_perms"
			result = {'users'=>{},'channels'=>{}}
			gresult.each do |row|
				result['users'][row['uid'].to_s] = Perms.new row['level'].to_i,{}
			end
			lresult.each do |row|
				uid,cid = row['ucid'].split("_")
				result['users'][uid.to_s] ||= Perms.new 0,{}
				result['users'][uid.to_s].local[cid.to_s] = row['level'].to_i
			end
			cresult = query "SELECT cid,perms FROM #{@dbparams['prefix']}_channel_perms"
			cresult.each do |row|
				result['channels'][row['cid'].to_s] = row['perms'].split ';'
			end
			return result
		end
	end
end

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
end
