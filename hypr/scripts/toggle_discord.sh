#!/usr/bin/env bash

# Nom du special workplace
WS_NAME="discord"

# Fonction pour trouver la fenetre discord
get_discord_addr() {
	hyprctl clients -j | jq -r '
		.[]
		| select((.class // "") | test("(?i)discord"))
		| .address
	'	| head -n1
}

DISCORD_ADDR=$(get_discord_addr)

# Si aucune fenetre Discord, on lance discord
if [ -z "$DISCORD_ADDR" ]; then
	if ! pgrep -x "discord" >/dev/null && ! pgrep -f "com.discordapp.Discord" >/dev/null; then
		discord & disown
	fi

	#On attend que la fenetre apparaisse
	for i in {1..50};do
		sleep 0.1
		DISCORD_ADDR=$(get_discord_addr)
		[ -n "$DISCORD_ADDR" ] && break
	done
fi

# Si on a une fenetre discord, on la met dans le special workspace
if [ -c "$DISCORD_ADDR" ]; then
	hyprctl dispatch movetoworkspacesilent "special:$WS_NAME, address:$DISCORD_ADDR"
fi

# Enfin on toggle le special workspace
hyprctl dispatch togglespecialworkspace "$WS_NAME"




