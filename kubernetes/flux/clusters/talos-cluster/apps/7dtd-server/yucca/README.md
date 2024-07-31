# 7DTD Server

## Configure Server Password

- within the pod, edit `/home/sdtdserver/serverfiles/sdtdserver.xml`
- set the value for `ServerPassword`

## Enable Webserver UI

- enable TCP port 8080 on the LoadBalancer
- set [`ALLOC_FIXES: "YES"`](https://7dtd.illy.bz/wiki/Server%20fixes) in the ConfigMap
  - check logs to ensure the fix is applied, [`VERSION` may need to be modified](https://github.com/vinanrra/Docker-7DaysToDie/blob/35e7994ba2292d79d1ca25558ed4d39c74695e99/scripts/Mods/alloc_fixes.sh#L8)
- within the pod, edit `/home/sdtdserver/serverfiles/sdtdserver.xml`
- set `WebDashboardEnabled` to `true`
- set `EnabledMapRendering` to `true` (optional, to display a map view)

## In-Game User Permissions

### Create an admin user

- within the game, use `createwebuser` command to create a web user
- within the pod, edit `/home/sdtdserver/.local/share/7DaysToDie/Saves/serveradmin.xml`
- under adminTools.users, create entry with `permissionLevel="0"`
  - this is used for in-game commands only
- under adminTools.webUsers, edit the new user entry to set `permissionLevel="0"`
  - this is used for webserver UI only
