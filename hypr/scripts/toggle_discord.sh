#!/usr/bin/env bash

WS_NAME="discord"

get_discord_addr() {
  hyprctl clients -j | jq -r '
    .[]
    | select(
        ((.class // "") | test("(?i)^discord$"))
        or
        (((.class // "") | test("(?i)^kitty$")) and ((.title // "") | test("(?i)^discord$")))
      )
    | .address
  ' | head -n1
}

discord_ADDR=$(get_discord_addr)

# Si aucune fenêtre discord, on lance discord
if [ -z "$discord_ADDR" ]; then
  if ! pgrep -x "discord" >/dev/null; then
    discord & disown
  fi

  # Attente apparition fenêtre
  for i in {1..80}; do
    sleep 0.1
    discord_ADDR=$(get_discord_addr)
    [ -n "$discord_ADDR" ] && break
  done
fi

# Si on a une fenêtre discord, on la met dans le special workspace
if [ -n "$discord_ADDR" ]; then
  hyprctl dispatch movetoworkspacesilent "special:$WS_NAME, address:$discord_ADDR"
fi

# Toggle du special workspace
hyprctl dispatch togglespecialworkspace "$WS_NAME"

