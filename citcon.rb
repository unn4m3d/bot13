require 'json'

jtx = JSON.parse(File.read(ARGV[0]))
output = {}
chats = {
	"1" => "-11333160"
} 
for citation in jtx["cit"] do
	puts "Converting citation id #{citation["id"]}, c"
	if citation["chan_id"].to_s == "1"
		cid = "-11333160"
		cit = {
			"text" => citation["text"],
			"date" => citation["time"].gsub(/^(\d\d\d\d)-(\d\d)-(\d\d)[\s\d:]*$/){"#{$3}/#{$2}/#{$1}"},
			"author" => citation["autor"],
			"moderated"=> true
		}
		output[cid] ||= []
		output[cid].push(cit)
	end
end
File.open(ARGV[1],"w") do |f|
	f.puts JSON.generate output
end
