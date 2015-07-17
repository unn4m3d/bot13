=begin
	Weather module
	v 1.0.0
=end
require 'net/http'
require 'uri'
require 'json'

checkfile($home + "/tmp"){
	|f|
	dwarning "[WARNING] Directory #{f} is missing. Creating it..."
	Dir.mkdir(f)
}


module Kochi_University
	IMG_TYPES = ["FE","SE","WV","SP","SD","QL","JPN","HF","HS"]
	HOST = "http://weather.is.kochi-u.ac.jp/"
end

module OpenWeatherMap
	HOST= "https://api.openweathermap.org/data/2.5/"
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

addcmd("w:fewi",0,Proc.new{
	|a,m|
	a[0] ||= "IR"
	name = $home+"/tmp/#{$lid}.jpg"
	download(Kochi_University::HOST+(Kochi_University::IMG_TYPES.include?(a[0].upcase)? a[0] : "IR") + "/00Latest.jpg",name)
	$bot.sendPhoto(m.source["chat"]["id"],name)
},10)


$help["w:fewi"] = HelpPage.new("/w:fewi","Satellite images from weather.is.kochi-u.ac.jp","Usage : /fewi (#{Kochi_University::IMG_TYPES.join(" | ")})")

def ktoc(k)
	return k - 273.15
end
