#Plugins manual

**Documentation** : [here](doc/index.html)

###How to write a basic HelloWorld plugin

The simpliest plugin is
```ruby
load do |config|
	puts "Hello, World!"
end
```

Put it into `plugins` folder with `.rb` or `.plg` extension

###Global variables

- `$bot` is a main bot instance
- `$cmdengine` is a main CmdEngine instance
- `$config` is a config hash
- `$options` is a parsed command line options hash

###Getting updates and setting timeout

For updates, you must use `$bot.addhandler(handler)`, as follows:
```ruby
$bot.addhandler(TgAPI::TgMessageHandler.new(
	Proc.new{ |update| # Yields Update object
		...
	},{} #This is an options hash. At the moment, it supports only "raw" boolean, that tells bot to yield Hash object instead of Update
))
```
`Update` object contains only 2 fields : `update_id` and `message`, which is `Message` object.



Also, you can use `$cmdengine.addcmd(command)`, as following:
```ruby
$cmdengine.addcmd(
	Bot13::Command.new(
		"mycommand",Proc.new{
			|e,c,m| #Yields CmdEngine,Command and Message
					#Use e.timer.set_timeout("mycommand",seconds,m.from.id.to_s) to set timeout
			...
		},0 # Permission level
	)
)
```

`Message` structure can be found [here](https://core.telegram.org/bots/api#message). It also contains two additional fields : `source` (the source hash object) and `_args` (text without first token)


###Sending message

To send message, you must call `$bot.sendMessage(...)`:
```ruby
	$bot.sendMessage(-10000000,"*Hello,World*",nil,nil,nil,"Markdown")
```
See also [YARD Documentation](doc/TgAPI/TgBot.html#sendMessage-instance_method)

###Plugin initial config and info

For creating initial config and info for your plugin, you must create a JSON file in `plugins` folder with name similar to your plugin's name, but with an additional extension `.json`.

For example, your plugin has name `mysup4plug1n.plg`. So your JSON must have name `mysup4plug1n.plg.json`.

The contents of this JSON must look like this:
```json
{
	"plugins":[
		{
			"name":"My Sup4 Plug1n",
			"author":"username111",
			"description":"My awesome uberplugin",
			"version":"0.0.1",
			"license":"MIT"
		},
		{
			"name":"My Sup4 P00p4 Plug1n ",
			"author":"username111",
			"description":"My awesome uberplugin #2",
			"version":"42.1337.1",
			"license":"GNU LGPL"
		}
	],
	"config":{
		"key1":"value1","a":"b"
	}
}
```

The `config` is passed into the load block :
```ruby
	load do |c|
		puts c
		#=>{"key1"=>"value1","a"=>"b"}
	end
```
