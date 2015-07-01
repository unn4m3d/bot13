# bot13 - independent version for Telegram.
Bot for <s>weechat</s> [Telegram](https://telegram.org) written in Ruby<br>

##How to launch
`cd /path/to/your/bot13/ && ruby ./core.rb`

##How to install
1. Copy `tgapi.rb`, `core.rb`, `api.rb`  folder into `$HOME/.bot13_telegram`


##Changelog
####v 3.0A (Telegram)
**WARNING** Plugins don't work<br>
**WARNING** Command processes are now calling with args `args,message`, not `args,user,channel`. `message` is of type TgAPI::Message. Use `message.source` and [Telegram BotAPI Message docs](https://core.telegram.org/bots/api#message)<br>
**WARNING** There is a bug : message.chat and message.from may be nil.
First telegram version<br>

####v 2.0.3A (Independent)
Colorized Bandit<br>
Added `!restart` command

####v 2.0.2A (Independent)
Fixed NickList<br>
Documented API<br>
Splitted API and Core 

####v 2.0.1A (Independent)
Fixed some minor bugs<br>
`!help` and `!perms get` now can work in private chat

####v 2.0A (Independent)
Now works outside of Weechat<br>
**WARNING** Plugins don't work at the moment<br>
**WARNING** NickList is deleted now<br>
New command : `!debug [<count>[ (<level>|<lowlevel> <highlevel>)[ <target>]]]`

####v 1.7.1B
<s>Now loads with loader.rb</s><br>
New help format
####v 1.7B
Now can work on several channels<br>
Upgraded bandit saving algorythm<br>
Upgraded !help<br>
Upgraded !cmds<br>
Upgraded bandit<br>
Added Reactions
####v 1.6.2B
Upgraded NickList : Now it can list users
####v 1.6.1B
Upgraded API; Added NickList class that provides nick info
####v 1.6B
Added Plugin API
####v 1.5B
Added permissions<br>
Added personal cmd timeout<br>
Now it can do stuff only at one channel
####v 1.4A
Bot now can be switched off. Use `/dbot on` and `/dbot off` to switch<br>
Added messages that are sent when user joins<br>
Upgraded parser<br>
Upgraded `!motd` command<br>
Added `!help` command
####v 1.3A
Refactored ~10 lines<br>
Fixed a bug with table of records<br>
Added timeout<br>
Added random messages
####v 1.2A
New bandit algorythm<br>
Fixed a bug that passed username instead of nick in command args
####v 1.1A 
New commands : `!cmds`, `!random [a[ b]]`, `!bandit`, `!winners`<br>
Upgraded parser : now reads correctly username,channel and special symbols
####v 1.0A
Initial release

