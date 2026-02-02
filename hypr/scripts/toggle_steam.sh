#!/usr/bin/env bash

WS_NAME="steam"

get_steam_addr() {
  hyprctl clients -j | jq -r '
    .[]
    | select(
        ((.class // "") | test("(?i)^steam$"))
        or
        (((.class // "") | test("(?i)^kitty$")) and ((.title // "") | test("(?i)^steam$")))
      )
    | .address
  ' | head -n1
}

STEAM_ADDR=$(get_steam_addr)

# Si aucune fenêtre Steam, on lance Steam
if [ -z "$STEAM_ADDR" ]; then
  if ! pgrep -x "steam" >/dev/null; then
    steam & disown
  fi

  # Attente apparition fenêtre
  for i in {1..80}; do
    sleep 0.1
    STEAM_ADDR=$(get_steam_addr)
    [ -n "$STEAM_ADDR" ] && break
  done
fi

# Si on a une fenêtre Steam, on la met dans le special workspace
if [ -n "$STEAM_ADDR" ]; then
  hyprctl dispatch movetoworkspacesilent "special:$WS_NAME, address:$STEAM_ADDR"
fi

# Toggle du special workspace
hyprctl dispatch togglespecialworkspace "$WS_NAME"

