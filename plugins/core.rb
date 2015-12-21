load do
	$cmdengine.addcmd(Bot13::Command.new(
		"bot13",
		Proc.new{
			|e,c,m|
			$bot.sendMessage(m.source['chat']['id'].to_s,"Bot-Th1rt3en v #{Bot13::VERSION}")
			e.timer.set_timeout(c.name,30,m.source['from']['id'].to_s)
		},
		0
	))
end
