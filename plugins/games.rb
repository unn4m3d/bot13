def DEFAULT_CHAT
	".default"
end

class InGameCash
	@@players = {}
	def self.set(player,chat,cash)
		@@players[player][chat] = cash
		self.save
	end
	
	def self.get(player,chat)
		p = @@players[player]
		c = 0
		return c unless p
		c += p[chat] if p[chat]
		c += p[DEFAULT_CHAT] if p[DEFAULT_CHAT]
		return c
	end
	
	def self.load
		@@players = JSON.parse File.read "#{$home}/data/gamecash.json"
	end
	
	def self.save
		File.open("#{$home}/data/gamecash.json","w") do |f|
			f.write(JSON.generate(@@players).gsub(/([{}\[\]])\s*,/,"$1\n,"))
		end
	end
end

class Bandit
	@@players = {}
	def self.load
		@@players = JSON.parse File.read "#{$home}/data/bandit.json"
	end
	
	def self.save
		File.open("#{$home}/data/bandit.json","w") do |f|
			f.write(JSON.generate(@@players).gsub(/([{}\[\]])\s*,/,"$1\n,"))
		end
	end
	
	def self.play(chat,player)
		num1 = Random.rand(10)
		msg("[#{num1}|-|-]",chat.to_s)
		num2 = Random.rand(10)
		msg("[#{num1}|#{num2}|-]",chat.to_s)
		num3 = Random.rand(10)
		m = "[#{num1}|#{num2}|#{num3}]"
		if num1 == num2 and num2 == num3 then
			m += getmsg("win") + "\nYou gain #{num1*100} #mapcoins"
			@@players[chat][num1.to_s] = player
			InGameCash.set(player,chat,InGameCash.get(player,chat)+(num1*100))
		else
			if num1==num2 or num2==num3 or num1==num3 then
				m += " Second chance"
				msg(m,chat.to_s)
				if num1 == num2 then
					num3 = Random.rand(10)
				elsif num2 == num3 then
					num1 = Random.rand(10)
				elsif num3 == num1 then
					num2 = Random.rand(10)
				end
				m = "[#{num1}|#{num2}|#{num3}] "
				if num1 == num2 and num3 == num2 then
					m += getmsg("win") + "\nYou gain #{num1*100} #mapcoins"
					@@players[chat][num1.to_s] = player
					InGameCash.set(player,chat,InGameCash.get(player,chat)+(num1*100))
				else
					m += getmsg("lose")
				end
			else
				m += " "+getmsg("lose")
			end
			msg(m,chat.to_s)
		end
	end
	
	def self.to_s(chat)
		m = "WinRARs:"
		begin
		@@players[chat].each do |k,v|
			m += "\n#{k*3} => #{v}"
		end
		end if @@players[chat]
		msg(m, chat.to_s)
	end
end

$help["#mapcoins"] = HelpPage.new("#mapcoins","in-game cash","#mapcoins is the in-game cash."+
	"It's name is formed from \"#mapc\", a name of IRC-channel where this bot was invented, and"+
	"\"coins\".#mapcoins is used to buy some useful stuff in a chats") 

addcmd("bandit",0,Proc.new{ |a,m|
	Bandit.play(m.source["chat"]["id"],m.source["from"]["username"])
},35)


addcmd("bandits",0,Proc.new{ |a,m|
	Bandit.to_s(m.source["chat"]["id"])
},35)

addcmd("vault",0,Proc.new{
	|a,m|
	msg("You have #{InGameCash.get(m.source["from"]["username"],m.source["chat"]["id"])} #mapcoins",m.source["chat"]["id"])
},35) 


