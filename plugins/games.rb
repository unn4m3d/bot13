=begin
	Games Plugin 1.1 Alpha for Bot13 1.6.1
	By unn4m3d
	
=end

$rscore = {}
$prices = {
	"voice" => 250,
	"halfop" => 1000,
	"perm" => 500,
}
$timers = {}

def roulette(user)
	if Random.rand(6) == 0
		msg("BANG, #{user}! R.I.P", $channel)
		$rscore[user] = 0
	else
		if not $rscore[user]
			$rscore[user] = 1
		end
		sc = Random.rand($rscore[user] + 10)
		$rscore[user] += sc
		msg("Click, #{user}! You're still alive! You gained #{sc} pounds", $channel)
	end
	r_save
end

def r_save()
	f = File.open($home + "/.bot13/roulette.cfg","w")
	for k in $rscore.keys()
		f.write(k + " " + $rscore[k].to_s + "\n")
	end
	f.close
end

def r_load()
	f = File.open($home + "/.bot13/roulette.cfg")
	while not f.eof?
		s = f.gets.split(" ")
		$rscore[s[0]] = s[1].to_i
	end
	f.close
end

def r_sort()
	arr = $rscore.keys
	i = 0
	j = 0
	while i < arr.size-1 
		while j < arr.size - i-1
			if $rscore[arr[j]] < $rscore[arr[j+1]] 
				arr[j],arr[j+1] = arr[j+1],arr[j]
			end
			j+=1
		end
		i+=1
	end
	return arr
end

class BattlePlayer
	attr_accessor:name,:fus,:atk,:hp,:arm,:lvl,:exp,:bp,:bw
	def initialize(n,f,a,h,arm,l,e)
		@name = n
		@fus = f
		@atk = a
		@hp = h
		@arm = arm
		@lvl = l
		@exp = e
	end
	
	def self.create(name)
		o = BattlePlayer.new(name,0,2,5,1,0,0)
		o.bp = 0
		o.bw = 0
		return o
	end
	
	def self.load(str)
		str = str.split(" ")
		o = BattlePlayer.new(str[0],str[1].to_i,str[2].to_i,str[3].to_i,str[4].to_i,str[5].to_i,str[6].to_i)
		o.bp = str[7].to_i
		o.bw = str[8].to_i
		return o
	end
	
	def to_s
		return [@name,@fus,@atk,@hp,@arm,@lvl,@exp,@bp,@bw].join(" ")
	end
	
	def shi
		return "#{@name}(#{@hp.to_s}/#{@arm.to_s}/#{@atk.to_s})[#{@lvl.to_s}]"
	end
end

$battle = {}

def newplayer(usr)
	if not $battle[usr]
		$battle[usr] = BattlePlayer.create
	end
end

def bt_save
	f = File.open($home + "/.bot13/battle.cfg","w")
	for k in $battle.keys
		f.write($battle[k].to_s + "\n")
	end
	f.close
end

def bt_load
	if File.exists?($home + "/.bot13/battle.cfg")
		f = File.open($home + "/.bot13/battle.cfg")
		ln = f.readlines
		f.close
		for l in ln
			bp = BattlePlayer.load(l)
			$battle[bp.name] = bp
		end
	end
end

def gt(u)
	return $battle[u]
end

def bt_hit(u1,u2,force)
	notice("You hit #{u2} and applied #{force} damage",u1)
	notice("You've been hit by #{u1} and taken #{force} damage", u2)
end

def bt(u1,u2,c)
	newplayer(u1)
	newplayer(u2)
	$list.update($server,c)
	h1 = $battle[u1].hp.clone
	h2 = $battle[u2].hp.clone
	msg("#{$c}5,0#{gt(u1).shi+$c} will fight with #{$c}5,0#{gt(u5).shi+$c}",c)
	while h1 > 0 and h2 > 0
		f = (Random.rand(1 + (2*gt(u1).lvl) + gt(u1).atk)/(gt(u2).lvl+gt(u2).arm)*2).ceil
		h2 -= f
		bt_hit(u1,u2,f)
		if h2 <= 0
			break
		end
		f = (Random.rand(1 + (2*gt(u2).lvl) + gt(u2).atk)/(gt(u1).lvl+gt(u1).arm)*2).ceil
		h1 -= f
		bt_hit(u2,u1,f)
	end
	if h1 > 0
		c_f = (1.5*gt(u1).lvl).ceil
		c_e = (1.5*((gt(u1).lvl-gt(u2).lvl).abs)+1).ceil
		c_l =(e/10).floor > gt(u1).lvl ? 1 : 0
		$battle[u1].fus += c_f
		$battle[u1].exp += c_e
		$battle[u1].lvl += c_l
	elsif h2 > 0
		c_f = (1.5*gt(u1).lvl).ceil
		c_e = (1.5*((gt(u1).lvl-gt(u2).lvl).abs)+1).ceil
		c_l =(e/10).floor > gt(u1).lvl ? 1 : 0
		$battle[u2].fus += c_f
		$battle[u2].exp += c_e
		$battle[u2].lvl += c_l
	else
		msg("Draw!",c)
	end
end

class RTimer
	attr_accessor:name,:cmd,:timeleft
	def initialize(m,t,n)
		@cmd = m
		@timeleft = t
		@name = n
	end
	
	def decrease()
		if @timeleft <= 0
			Weechat.command($buf_pntr,@cmd)
			$timers[@name] = nil
		else
			@timeleft-=1
		end
	end
end

def addrt_r(timer)
	if ($timers[timer.name] and $timers[timer.name].cmd == timer.cmd)
		timer.timeleft += $timers[timer.name].timeleft
	end
	$timers[timer.name] = timer
end



def onload
	addcmd("!roulette", 0, Proc.new{
		|a,u,c|
		if a[0] == "top"
			arr = r_sort
			i = 0
			while i < 5 and i < arr.size
				msg(i.to_s + ":" + arr[i] + " " + $rscore[arr[i]].to_s, c)
				i+=1
			end
			
		elsif a[0] == "stat" or a[0] == "стат"
			if a[1] == nil
				if $rscore[u]
					msg("#{u} заработал #{$rscore[u].to_s} тугриков", c)
				else
					msg("Я не знаю тебя, #{u}",c)
				end
			else
				if $rscore[a[1]]
					msg("#{a[1]} заработал #{$rscore[a[1]].to_s} тугриков", c)
				else
					msg("Я не знаю #{a[1]}",c)
				end
			end
		else
			if ($rscore[u] != nil and $rscore[u] > 0) or not $rscore[u]
				roulette(u)
			elsif $rscore[u] < 1
				Weechat.command("","/notice #{u} Ты уже мертв, #{u}!")
			end
		end
	},30)
	addcmd("!rset",4, Proc.new{
		|a,u,c|
		if a.length > 1
			$rscore[a[0]] = a[1].to_i
		else
			msg("RSet:Usage: !rset [nick] [amount]", c)
		end
	},1)
		
		
	addcmd("!buy", 0, Proc.new{
		|a,u,c|
		if $rscore[u] == nil
			msg("Buy :  У вас нет счета в рулетке",u)
			return
		end
		if a.length == 2
			if $prices[a[0]] != nil 
				if $prices[a[0]] * Integer(a[1]) < $rscore[u]
					if a[0] == "voice"
						Weechat.command($buf_pntr, "/mode +v #{u}")
						addrt_r(Timer.new("/mode -v #{u}",60*Integer(a[1]),u))
					elsif a[0] == "halfop"
						Weechat.command($buf_pntr, "/mode +h #{u}")
						addrt_r(Timer.new("/mode -h #{u}",60*Integer(a[1]),u))
					elsif a[0] == "perm"
						Permissions.set(u,Integer(a[1]))
					end
					$rscore[u] -= Integer(a[1])*$prices[a[0]]
				else
					msg("Buy : Недостаточно денег, #{u}!",c)
				end
			else
				msg("Buy:Usage: !buy (voice|halfop) <time>",c)
				msg("Buy:Usage: !buy perm <lvl>",c)
			end
		else
			msg("Buy:Usage: !buy (voice|halfop|perm) time",c)
		end
	},1)
	
	addcmd("!fight",0,Proc.new{
		|a,u,c|
		usrs = NickList.new(c).list
		u2 = usrs[Random.rand(usrs.length)]
		bt(u,u2,c)
		bt_save
	},120)
	if not File.exists?($home + "/.bot13/roulette.cfg")
		r_save
	end
	if not File.exists?($home + "/.bot13/roulette.cfg")
		bt_save
	end
	addhelp("!рулетка", "Русская Рулетка",
	["Usage : !roulette [(стат|stat) [user]]"])
	addalias("!рулетка", "!roulette")
	r_load
	bt_load
	register_plugin("GameZZ","1.1","unn4m3d",LOCALE::RUS,"Games for Bot13","GNU GPLv3")
end

onload
