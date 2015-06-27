=begin
	Grammatic-mistakes morfer =)
	v 1.0 by unn4m3d
=end

addreact([/^[a-zA-Z0-9\ ]$/], Proc.new{
	|u,c,m|
	if Random.rand(10) > 8
		for a in (0...m.length)
			if Random.rand(50) > 32
				m[a] = ('a'..'z')[Random.rand(('a'..'z').length)]
				if Random.rand(50) > 39
					m[a] = m[a].upcase
				end
			end
		end
		msg("<#{u}> : #{m}",c)
	end
})
	
addreact([/^[а-яА-Я0-9\ ]$/], Proc.new{
	|u,c,m|
	if Random.rand(10) > 8
		for a in (0...m.length)
			if Random.rand(50) > 32
				m[a] = ('а'..'я')[Random.rand(('а'..'я').length)]
				if Random.rand(50) > 39
					m[a] = m[a].upcase
				end
			end
		end
		msg("<#{u}> : #{m}",c)
	end
})
