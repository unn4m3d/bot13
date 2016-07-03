#Bot configuration

###How to fill data/config.json

`data/config.json` must have following structure :
```json
{
	"token":"YOUR_TOKEN",
	"storage":{
		"enable":true,
		"driver":{
			"class":"Bot13::Storage::JSONStorageDriver",
			"params":"data/storage.json"
		}
	},
	"perms":{
		"driver":{
			"class":"Bot13::JSONPermDriver",
			"params":"data/permissions.json"
		}
	}
}
```
`token` is your Telegram Bot token.

###How to fill data/permissions.json

`data/permissions.json` must look like this:

```json
	{
		"users":[
			"11201212":{"global":0,"chats":{
					"-11333160":1,
					"-11333159":100,
					...
				}
			},
			...
		]
	}
```

Numbers in keys (`11201212`,`-11333160` and `-11333159`) are User IDs and Chat IDs, numeric values are permission levels.

###How to fill data/channels.json

`data/channels.json` must look like this :
```json
	{
		"-11333160":["bot13","quote","weather","daenerys_mode"],
		"-11333159":["lol","bot13"]
	}
```

**NOTE** If channel is not specified, all permissions are allowed
