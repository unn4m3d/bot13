=begin
	Social plugin 1.0.1 Alpha RUS for Bot13 1.7
	By unn4m3d
	Changelog:
		v 1.0.1 Alpha RUS
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
			@parser.call(u,u2)
		elsif $list.search(a[0]) == true
			@parser.call(u,a[1])
		else
			Weechat.command($buf_pntr,"/notice #{u} Нет такого пользователя '#{a[0]}'!")
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
	msg("#{u1} надул #{u2}, и #{u2.upcase} улетел в небеса!",c)
})

addsocial("!deflate", Proc.new{
	|u1,u2|
	msg("#{u1} проткнул #{u2}, иголкой и #{u2.lowercase} шлепнулся на землю!",c)
})

addsocial("!rotate", Proc.new{
	|u1,u2|
	msg("#{u1} развернул #{u2}, и получилось #{u2.reverse}",c)
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
	msg("#{u1} вручил #{u2} бутылку с этикеткой \"#{cd}\". #{u2} #{ca}",c)
})

addalias("!напиток","!drink")
addalias("!сдуть","!deflate")
addalias("!надуть","!inflate")
addalias("!развернуть","!rotate")
