# bot13 - independent version for Telegram.
Bot for <s>weechat</s> [Telegram](https://telegram.org) written in Ruby<br>

[How to write plugins](PLUGINS.md) **|** [How to configure bot](CONFIG.md)

##Dependencies

####Gems
2. `telegram-bot-ruby`

##How to launch
`ruby ./core.rb`
See `ruby ./core.rb -h` for more info

##How to install

- `git clone https://github.com/unn4m3d/bot13 -b telegram`
- Download [update] and launch it either with `./update git` or `./update zip` 


##TODO
- [ ] API Documentation
- [ ] Startup scripts
- [ ] Plugin ports from 3.0 
- [ ] Remote control

##Changelog
####v 3.3 (Telegram)
New API and plugin format

####v 3.2.2A (Telegram)
Fixed missing plugin data<br/>
Removed some debug messages

####v 3.2.1A (Telegram)
Wrote some documentation<br>
Fixed some bugs

####v 3.2.0A (Telegram)
Full rewrite<br>
New API

####v 3.0.2A (Telegram)
Implemented PAPI v 2.0<br>
Upgraded TgAPI : added `TgAPI::TgBot#sendChatAction` and `TgAPI::TgBot#sendPhoto`<br>

####v 3.0.1A (Telegram)
No answers printed on getUpdates<br>
Added `/help`

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
**WARNING** Plugins aren't working at the moment<br>
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

