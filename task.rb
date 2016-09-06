require 'mysql2'
require 'telegram/bot'
module Quotes
	class Connection
		@@instance = nil
		attr_accessor:conn,:pref
		def initialize(h,p,u,pass,d,pref)
			@pref = pref
			@conn = Mysql2::Client.new(:host=>h, :port=>p, :username=>u, :password=>pass,:database=>d)
			query "SET NAMES UTF8"
		end

		def query(q)
			puts q
			@conn.query q
		end

		def close
			@conn.close
		end

		def count(cid)
			query("SELECT COUNT(qid) FROM #{@pref}quotes WHERE cid = #{cid.to_i} AND qid IS NOT NULL").to_a[0]['COUNT(qid)']
		end

		def by_id(cid,qid)
			query("SELECT * FROM #{@pref}quotes WHERE cid = #{cid.to_i} AND qid = #{qid.to_i}").to_a
		end

		def random(cid)
			by_id(cid,Random.rand(count(cid)))
		end

		def search(cid,phrase)
			query("SELECT * FROM #{@pref}quotes WHERE cid = #{cid.to_i} AND text LIKE '%#{@conn.escape phrase}%' AND qid IS NOT NULL LIMIT 100").to_a
		end

		def addq(cid,cit,aut)
			query "INSERT INTO #{@pref}quotes (cid,qid,date,author,text) VALUES(#{cid.to_i},NULL,'#{@conn.escape Time.now.strftime("%d.%m.%Y")}','#{@conn.escape aut}', '#{@conn.escape cit}')"
		end

		def self.instance
			@@instance
		end

		def self.instance=(i)
			@@instance = i
		end
	end

	def md_b(m)
		m ? "*" : ""
	end

	def d(_d)
		if not _d or _d.match(/^[0\.\/]+$/) or _d.strip == ""
			""
		else
			"/#{_d.gsub(/\//,'.')}"
		end
	end

	def formatq(r,count=0,md=false)
		"{#{md_b md}#{r['qid']+1}/#{count}#{md_b md}} #{r['text']} {#{md_b md}#{r['author']}#{d(r['date'])}#{md_b md}}"
	end
	module_function:formatq,:md_b,:d
end

lines = File.read(File.join(File.dirname(__FILE__),"chats")).each_line
Quotes::Connection.instance = Quotes::Connection.new(*(ARGV[0...6]))
Telegram::Bot::Client.run(ARGV[6]) do |bot|
	lines.each do |line|
		bot.api.send_message chat_id: line, text: 
"#плановая_цитата\n"+Quotes.formatq(Quotes::Connection.instance.random(line).first,Quotes::Connection.instance.count(line))
	end
end
