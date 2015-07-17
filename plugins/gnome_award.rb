awards = [
	$home + "data/ga1.jpg",$home+"data/ga2.jpg",$home+"data/ga3.jpg"
]

addcmd("жжош",0,Proc.new{|a,m|$bot.sendPhoto(m.source["chat"]["id"],awards[0])},0)
addcmd("зачот",0,Proc.new{|a,m|$bot.sendPhoto(m.source["chat"]["id"],awards[1])},0)
addcmd("кгам",0,Proc.new{|a,m|$bot.sendPhoto(m.source["chat"]["id"],awards[2])},0)
