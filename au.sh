#!/data/data/com.termux/files/usr/bin/bash

# ==== Config ====
APP_DIR="/data/data/com.ChillyRoom.DungeonShooter"
FILES_DIR="$APP_DIR/files"
PREF_DIR="$APP_DIR/shared_prefs"  # Default Android XML storage
OLD_CONFIG="$PREF_DIR/com.ChillyRoom.DungeonShooter.v2.playerprefs.xml"
TEMPLATE_FILE="$PREF_DIR/com.ChillyRoom.DungeonShooter.v2.playerprefs.txt"

ACC_FILE="$APP_DIR/acc.txt"
DONE_FILE="$APP_DIR/done.txt"
TMP_FILE="$APP_DIR/.acc_tmp.txt"
# ==== 6. Close and Relaunch ====
echo "[*] Killing app..."
am force-stop com.ChillyRoom.DungeonShooter
clear

# ==== 1. Pick random account from acc.txt ====
if [[ ! -f "$ACC_FILE" ]]; then
    echo "[!] Account file not found: $ACC_FILE"
    exit 1
fi

SELECTED_LINE=$(shuf -n 1 "$ACC_FILE")

if [[ -z "$SELECTED_LINE" ]]; then
    echo "[!] No valid line found in acc.txt"
    exit 1
fi

EMAIL=$(echo "$SELECTED_LINE" | cut -d'|' -f1)
PASS=$(echo "$SELECTED_LINE" | cut -d'|' -f2)
USER_ID=$(echo "$SELECTED_LINE" | cut -d'|' -f3)
TOKEN=$(echo "$SELECTED_LINE" | cut -d'|' -f4)

echo "[+] Selected account:"
echo "    Email : $EMAIL"
echo "    Pass  : $PASS"
echo "    ID    : $USER_ID"
echo "    Token : $TOKEN"

# ==== 2. Copy and rename data files ====
FILES=(
    "item_data_1_.data"
    "season_data_1_.data"
    "statistic_1_.data"
    "weapon_evolution_data_1_.data"
)

for FILENAME in "${FILES[@]}"; do
    OLD_PATH="$FILES_DIR/$FILENAME"
    NEW_FILENAME="${FILENAME//1_/${USER_ID}_}"
    NEW_PATH="$FILES_DIR/$NEW_FILENAME"

    if [[ -f "$OLD_PATH" ]]; then
        cp "$OLD_PATH" "$NEW_PATH" && echo "[+] Copied → $NEW_FILENAME"
    else
        echo "[!] Missing file: $FILENAME"
    fi
done

# ==== 3. Remove old XML config ====
if [[ -f "$OLD_CONFIG" ]]; then
    rm "$OLD_CONFIG" && echo "[+] Removed old XML config"
else
    echo "[!] No config XML to remove"
fi

# ==== 4. Generate new config from template ====
if [[ -f "$TEMPLATE_FILE" ]]; then
    MODIFIED=$(sed -e "s/98989898/$USER_ID/g" -e "s/anhhaideptrai/$TOKEN/g" "$TEMPLATE_FILE")
    echo "$MODIFIED" > "$OLD_CONFIG" && echo "[+] New XML config written"
else
    echo "[!] Template not found: $TEMPLATE_FILE"
fi

# ==== 5. Move used line to done.txt and remove from acc.txt ====
echo "$SELECTED_LINE" >> "$DONE_FILE"
grep -vFx "$SELECTED_LINE" "$ACC_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$ACC_FILE"
echo "[✓] Account moved to done.txt"

# ==== 6. Launch app ====
echo "[✓] Launching app..."
monkey -p com.ChillyRoom.DungeonShooter -c android.intent.category.LAUNCHER 1
