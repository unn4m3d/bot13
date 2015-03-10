=begin
	Battle Plugin for Bot13 1.6 Beta
=end

class Player
	attr_accessor :name,:fus,:atk,:arm,:hlt,:lvl
	def geti()
		return @name + " " + @fus.to_s + " " + @atk.to_s + " " + @arm.to_s + " " + @hlt.to_s + " " + @lvl.to_s
	end
	def initialize(s)
		sp = s.split(" ")
		@name = sp[0]
		@fus = sp[1]
		@atk = sp[2]
		@arm = sp[3]
		@hlt = sp[4]
		@lvl = sp[5]
	end
end


