=begin
	Social plugin 1.1 Beta for Bot13 2.0.3
	By unn4m3d
	
	Changelog:
	v 1.1 Beta [2.0.3]
	>Fixed for Independent Alpha
	>Upgraded !vodka
	
	v 1.0 Alpha [1.6.2]
	>Initial release
=end

class SocialCommand
	attr_accessor:parser,:alias
	def set(p)
		@parser = p
	end
	def execute(a,u,c)
		$list.update($server,c)
		nl = $list.list
		if not a[0]
			u2 = nl[Random.rand(nl.size)]
			@parser.call(u,u2,c)
		elsif $list.search(a[0]) == true
			@parser.call(u,a[0],c)
		else
			notice("There's no user '#{a[0]}' on this channel",u)
		end
	end
end

def addsocial(name,parser)
	sc = SocialCommand.new
	sc.set(parser)
	$cmds[name] = sc
end

addsocial("!inflate", Proc.new{
	|u1,u2,c|
	msg("#{u1} has inflated #{u2}, and #{u2.upcase} has flown into the sky!",c)
})

addsocial("!deflate", Proc.new{
	|u1,u2,c|
	msg("#{u1} has deflated #{u2}, and #{u2.downcase} has hit to the ground!",c)
})

addsocial("!rotate", Proc.new{
	|u1,u2,c|
	msg("#{u1} has rotated #{u2}, and now #{u2} is known as #{u2.reverse}",c)
})

addsocial("!vodka", Proc.new{
	|u1,u2,c|
	vodka = [
		"Stolichnaya",
		"M9CHOu PY/\ET",
		"Kalium cyanide. WAIT, OH SHI~",
		"Belenkaya",
		"GitHub.IO",
		"Alcohol 120%",
		"vodka-1.0.0-amd64.deb",
	]
	actions = [
		"drinked it and falled asleep",
		"drinked it and shouted, \"N00B!\"",
		"drinked it and died. R.I.P",
		"drinked it and shouted \"What's the fuck??!\"",
		"drinked it and said \"git pull origin master\"",
		"drinked it and lol'd",
		"didn't drink it because of missing dependencies 'libalcohol-dev' and 'libglass-dev'"
	]
	ca = actions[Random.rand(actions.size)]
	cd = vodka[Random.rand(vodka.size)]
	msg("#{u1} gave #{u2} a bottle labeled \"#{cd}\". #{u2} #{ca}",c)
})

register_plugin("Social","1.1","unn4m3d","ENG","Some commands","GNU GPLv3")
