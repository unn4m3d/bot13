# bot13
Bot for weechat written in Ruby

##How to launch
/ruby load /path/to/your/core.rb

##How to install
####On Linux
	Move papi.rb and plugins folder into ~/.bot13 folder
####On Windows
	Move papi.rb and plugins into %APPDATA%\.bot13\

##Changelog
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

