=begin
	Weather module
	v 1.0.0
=end
require 'net/http'
require 'uri'

checkfile($home + "/.bot13_telegram/tmp"){
	|f|
	dwarning "[WARNING] Directory #{f} is missing. Creating it..."
	Dir.mkdir(f)
}

module Kochi_University
	IMG_TYPES = ["FE","SE","WV","SP","SD","QL","JPN","HF","HS"]
	HOST = "http://weather.is.kochi-u.ac.jp/"
end

def download(r,l)
	uri = URI(r)
	Net::HTTP.start(uri.host,uri.port) do |h|
		r = h.get(uri.path)
		File.open(l,"wb") do |f|
			f.write(r.body)
		end
	end
end

addcmd("fewi",0,Proc.new{
	|a,m|
	a[0] = "IR" unless a[0]
	name = $home + "/.bot13_telegram/tmp/#{$lid}"
	download(Kochi_University::HOST+(Kochi_University::IMG_TYPES.include?(a[0].upcase)? a[0] : "IR") + "/00Latest.jpg",name + ".jpg")
	$bot.sendPhoto(m.source["chat"]["id"],name + ".jpg")
},10)

$help["fewi"] = HelpPage.new("/fewi","Satellite images from weather.is.kochi-u.ac.jp","Usage : /fewi (#{Kochi_University::IMG_TYPES.join(" | ")})")
