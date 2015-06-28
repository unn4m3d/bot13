# bot13 - independent version.
Bot <s>for weechat</s> written in Ruby<br>
**WARNING** This is not ready. I've just created the branch at the moment

##How to launch
/ruby load /path/to/your/core.rb

##How to install
1. Copy `papi.rb`, `core.rb` and `plugins` folder into `$HOME/.bot13`
2. Make sure there is no backup files (files with name ended with `~`) in `plugins`
3. `cd $HOME/.weechat/ruby/autoload && ln -s $HOME/.bot13/core.rb` or move `core.rb` into `$HOME/.weechat/ruby/autoload`


##Changelog
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
New commands : `!cmds`, `!random [a[,b]]`, `!bandit`, `!winners`<br>
Upgraded parser : now reads correctly username,channel and special symbols
####v 1.0A
Initial release

