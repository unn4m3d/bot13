=begin
	Russian Roulette Plugin 1.1 Alpha for Bot13 1.6.1
	By unn4m3d
	:::RUSSIAN TRANSLATION:::
=end

$rscore = {}
$prices = {
	"voice" => 250,
	"halfop" => 1000,
	"perm" => 500
}
$timers = {}

def roulette(user)
	if Random.rand(6) == 0
		msg("БАХ! Ты прострелил себе висок, #{user}! R.I.P", $channel)
		$rscore[user] = 0
	else
		if not $rscore[user]
			$rscore[user] = 1
		end
		sc = Random.rand($rscore[user] + 10)
		$rscore[user] += sc
		msg("Осечка, #{user}! Ты жив! Ты заработал #{sc} тугриков", $channel)
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
	if not File.exists?($home + "/.bot13/roulette.cfg")
		r_save
	end
	addhelp("!рулетка", "Русская Рулетка",
	"Usage : !roulette [(стат|stat) [user]]")
	addalias("!рулетка", "!roulette")
	r_load
end

onload
