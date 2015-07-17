cit = JSON.parse File.read $home + "/data/citations.json"

addcmd("quote",0,Proc.new{
	|a,m|
	chat = m.source["chat"]["id"]
	if cit[chat.to_s]
		length = cit[chat.to_s].length
		n = Random.rand(length)
		c = false
		if a[0] then
			if a[0].to_s.match(/^[0-9]+$/)
				n = a[0].to_i-1
			else
				msgs = []
				for ms in (0...cit[chat.to_s].length)
					if cit[chat.to_s][ms]["text"].include?(m._args)
						msgs.push(ms)
					end
				end
				c = true
				om = "Citations with this text:"
				om = "No citations found!" if msgs.length <= 0
				for ms in msgs
					om += "{#{(ms+1).to_s}}"
				end
				msg(om,m.source["chat"]["id"])
			end
		end
		unless c
			msg("[#{n+1}/#{cit[chat.to_s].length}]#{cit[chat.to_s][n]["text"]}[#{cit[chat.to_s][n]["author"]}#{cit[chat.to_s][n]["date"].gsub("/",".") != "00.00.0000" ? "/#{cit[chat.to_s][n]["date"].gsub("/",".")}" : ""}]",m.source["chat"]["id"])
		end
	else
		msg("No citations! ",chat)
	end	
},60)

addcmd("quote+",0,Proc.new{
	|a,m|
	chat = m.source["chat"]["id"]
	cit[chat.to_s] = [] unless cit[chat.to_s]
	cit[chat.to_s].push({"text"=>m._args,"author"=>m.source["from"]["username"],"date"=>Time.now.strftime("%d.%m.%Y")})
	msg("Thanks, your citation is pushed",chat)
	f = File.open($home + "/data/citations.json","w")
	f.puts(JSON.generate(cit))
	f.close
},60)

tg = Timers::Group.new
sec = Random.rand(60*15)+(60*15)
dinfo "[INFO] Installing RCT to #{sec} seconds interval"
tg.every(sec){
	for ch in $config["chats"] do
		if cit[ch.to_s] and cit[ch.to_s].length > 0 then
			n = Random.rand(cit[ch.to_s].length)
			msg(cit[ch.to_s][n],ch)
		end
	end
}

dinfo "[INFO] Loaded successfully"
