=begin
	Russian Roulette Plugin for Bot13 1.6
	By unn4m3d
=end

$rscore = {}

def roulette(user)
	if Random.rand(6) == 0
		msg("#{user}, you're dead!", $channel)
		$rscore[user] = 0
	else
		if not $rscore[user]
			$rscore[user] = 1
		end
		sc = Random.rand($rscore[user] + 10)
		$rscore[user] += sc
		msg("#{user}, you're alive! LOL! You receive #{sc} points", $channel)
		
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
			
		elsif a[0] == "stat"
			if a[1] == nil
				if $rscore[u]
					msg("#{u} gained #{$rscore[u].to_s} points in RR", c)
				else
					msg("I don't know you, #{u}",c)
				end
			else
				if $rscore[a[1]]
					msg("#{a[1]} gained #{$rscore[a[1]].to_s} points in RR", c)
				else
					msg("I don't know #{a[1]}",c)
				end
			end
		else
			if ($rscore[u] != nil and $rscore[u] > 0) or not $rscore[u]
				roulette(u)
			elsif $rscore[u] < 1
				Weechat.command("","/notice #{u} You're dead!")
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
end

onload