#!/bin/bash

confDirs=( "Sim Tech Documents" )

calendars=( "Spring 2024 Sim Calendar.docx" )
syncDirs=( /od_st/onedrive/Calendars /od_st/sim_tech_docs )
lastMod=()

CalSync () {
	i=0
	for fileName in "${calendars[@]}"; do
		modTimes=()
		for dir in "${syncDirs[@]}"; do
			modTimes+=( "$(ls -lh "$dir" | grep "$fileName" | sed 's/  / /g' | cut -d\  -f6-8)" )
		done
		if [ "${modTimes[0]}" != "${modTimes[1]}" ] && [ "${modTimes[$i]}" != "${lastMod[$i]}" ]; then
			echo "Updated calendar $fileName" 
			cp "${syncDirs[0]}/$fileName" "${syncDirs[1]}/$fileName"
		fi
		lastMod[i]="${modTimes[i]}" 
		
		i=$((i+1))
	done
}

apikey="$(cat ~/.config/syncthing/config.xml | grep apikey | cut -d\> -f2 | cut -d\< -f1)"
folder_id="ehxxc-gtbsp"

if [[ $(ls -a ~ | grep ".tmp-config" | wc -l) -eq 1 ]]; then
	if [[ $(ls ~/.config | wc -l) -eq 0 ]]; then
		mv ~/.tmp-config/* ~/.config
	fi
	rm -rf ~/.tmp-config
fi

while true; do
	#syncthing
	syncthing &
	#st_pid=$!
	sleep 5s #wait to establish connection
	st_stat=0
	while [ "$st_stat" != "idle" ]; do
		st_stat="$(curl -X GET -H "X-API-Key: $apikey" http://localhost:8384/rest/db/status?folder=$folder_id | grep state | head -1 | cut -d\" -f4)"
		sleep 5s
	done
	syncthing cli operations shutdown
	#kill $st_pid

	onedrive --synchronize --sync-shared-folders --force
	CalSync
	onedrive --confdir="~/.config/Sim Tech Documents" --synchronize
done
