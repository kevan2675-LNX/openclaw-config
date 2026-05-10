# Heartbeat Loop
Every 15 minutes, perform these background system tasks:

## Gaming Protection (Silence Mode)
- Check active system processes for any running games (e.g., "hl2.exe", "tf2", "left4dead2", "steam").
- **If a game is running, abort the heartbeat immediately.** Sleep silently. Do not run any system checks, do not push any notifications, and do not disrupt the CPU. Priority is 100% on game performance.

## System Monitoring (NixOS Rebuilds)
- If no games are running, check if the last NixOS system rebuild or Home Manager switch failed.
- If a system rebuild failed, push a quiet, helpful notification to my Web Dashboard so I can check it when I'm ready. Otherwise, stay silent in the background.
