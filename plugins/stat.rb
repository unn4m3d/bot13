=begin
	Statistics
=end

$stat_root = "/var/www/html"
$uses = {
	"bandit" => true,
	"roulette" => true
}

def stat_u
	if $uses["bandit"]
		s = "<table><tr><td>Number</td><td>Winner</td></tr><br>\n"
		for k in $bandits.keys
			s += "<tr><td>#{k.to_s*3}</td><td>#{$bandits[k]}</td></tr>\n"
		end
		s += "</table>"
		f = File.open($stat_root + "/bandit.php","w")
		f.write(s)
		f.close
	end
	
	if $uses["roulette"]
		s = "<table><tr><td>Player</td><td>Score</td></tr><br>\n"
		for k in $rscore.keys
			s += "<tr><td>#{k}</td><td>#{$rscore[k].to_s}</td></tr>\n"
		end
		s += "</table>"
		f = File.open($stat_root + "/rr.php","w")
		f.write(s)
		f.close
	end
	
end
