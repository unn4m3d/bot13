=begin
	Social plugin 1.1 Alpha RUS for Bot13 1.7
	By unn4m3d
	Changelog:
		v 1.1 Alpha RUS
		>Translated it and added russian aliases
=end

class SocialCommand
	attr_accessor:parser
	def set(p)
		@parser = p
	end
	def execute(a,u,c)
		if not a[0]
			$list.update($server,c)
			nl = $list.list
			u2 = nl[Random.rand(nl.size)]
			msg(@parser.call(u,u2),c)
		elsif $list.search(a[0]) == true
			msg(@parser.call(u,a[1]),c)
		else
			Weechat.command($buf_pntr,"/notice #{u} There's no user '#{a[0]}' on this channel")
		end
	end
end

def addsocial(name,parser)
	sc = SocialCommand.new
	sc.set(parser)
	$cmds[name] = sc
end

addsocial("!inflate", Proc.new{
	|u1,u2|
	return "#{u1} has inflated #{u2}, and #{u2.upcase} has flown into the sky!"
})

addsocial("!deflate", Proc.new{
	|u1,u2|
	return "#{u1} has deflated #{u2}, and #{u2.lowercase} has hit to the ground!"
})

addsocial("!rotate", Proc.new{
	|u1,u2|
	return "#{u1} has rotated #{u2}, and now #{u2} is #{u2.reverse}"
})

addsocial("!drink", Proc.new{
	|u1,u2|
	vodka = [
		"Столичная",
		"M9CHOu PY/\ET",
		"Цианид калия. WAIT, OH SHI~",
		"Беленькая",
		"GitHub.IO",
		"Alcohol 120%",
		"Произведено Геннадием Малаховым."
	]
	actions = [
		"выпил и уснул",
		"выпил и закричал : \"N00B!\"",
		"выпил и сдох. R.I.P",
		"выпил и воскликнул \"Што за срань тут творится??\"",
		"выпил и набрал в терминале \"git pull origin master\"",
		"выпил и MDR",
		"поглядел на этикетку и отказался"
	]
	ca = actions[Random.rand(actions.size)]
	cd = vodka[Random.rand(vodka.size)]
	return "#{u1} has given #{u2} a bottle with label \"#{cd}\". #{u2} #{ca}"
})

addalias("!напиток","")
addalias("!напиток","")
addalias("!напиток","")
