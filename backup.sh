#!/usr/bin/env bash
# Refresh the off-machine backups kept on the NAS via Synology Drive.
#
# Writes two files into the Synology Drive sync folder and waits for the client
# to confirm each one actually reached the NAS:
#
#   keys.tar.gz.gpg   ~/.gnupg + ~/.ssh, AES256 with a passphrase you choose
#   aws-config        ~/.aws/config (SSO profile definitions; NO credentials)
#
# Everything else on a dev Mac is recreatable - see RESTORE.md. Usage:
#   ./backup.sh              # refresh both
#   ./backup.sh --keys-only  # skip the aws config
set -euo pipefail

DEST="${BACKUP_DEST:-$HOME/SynologyDrive/mac-migration}"
# Stage on the same filesystem but OUTSIDE the sync folder: writing straight
# into it lets the sync client open the file while gpg is still streaming,
# which logs a read timeout and forces a retry. mv within a filesystem is
# atomic, so the client only ever sees a complete file.
STAGE="$HOME/.backup-staging"

keys_only=0
[ "${1:-}" = "--keys-only" ] && keys_only=1

mkdir -p "$DEST" "$STAGE"
trap 'rm -rf "$STAGE"' EXIT
umask 077

echo "==> Encrypting ~/.gnupg + ~/.ssh"
echo "    You will be asked for a passphrase twice."
echo "    Store it in 1Password - NOT on the NAS."
tar --exclude='S.*' --exclude='.#lk*' --exclude='random_seed' \
    --exclude='pubring.kbx~' --exclude='known_hosts.old' --exclude='.ssh/agent' \
    -czf - -C "$HOME" .gnupg .ssh \
  | gpg --symmetric --cipher-algo AES256 -o "$STAGE/keys.tar.gz.gpg"
mv -f "$STAGE/keys.tar.gz.gpg" "$DEST/keys.tar.gz.gpg"
echo "    $(du -h "$DEST/keys.tar.gz.gpg" | cut -f1)"

if [ "$keys_only" = 0 ] && [ -f "$HOME/.aws/config" ]; then
  if grep -qiE 'aws_secret_access_key|aws_session_token' "$HOME/.aws/config"; then
    echo "!!  ~/.aws/config contains credentials, not just profiles - skipping."
    echo "    Move the keys to ~/.aws/credentials, then re-run."
  else
    cp "$HOME/.aws/config" "$STAGE/aws-config"
    mv -f "$STAGE/aws-config" "$DEST/aws-config"
    echo "==> aws-config ($(grep -c '^\[profile' "$DEST/aws-config") profiles)"
  fi
fi

# ---------------------------------------------------------------- verify
echo "==> Verifying the archive decrypts (passphrase is cached, no re-prompt)"
if gpg --batch --pinentry-mode cancel --decrypt "$DEST/keys.tar.gz.gpg" 2>/dev/null \
     | tar -tzf - | grep -qE 'private-keys-v1.d/.*\.key'; then
  echo "    OK - secret keys present inside the archive"
else
  echo "!!  Could not verify contents (passphrase may not be cached)."
  echo "    Check by hand: gpg --decrypt '$DEST/keys.tar.gz.gpg' | tar -tzf -"
fi

# ---------------------------------------------------------------- sync
DB="$HOME/Library/Application Support/SynologyDrive/data/db"
if [ ! -f "$DB/file-status.sqlite" ]; then
  echo "==> Synology Drive not installed here; files are in $DEST but NOT uploaded."
  exit 0
fi

echo "==> Waiting for Synology Drive to upload (remote link is slow, be patient)"
for i in $(seq 1 60); do
  pending=$(sqlite3 "file:$DB/file-status.sqlite?mode=ro" \
            "SELECT count(*) FROM fstatinfo;" 2>/dev/null || echo "?")
  [ "$pending" = "0" ] && { echo "    uploaded - nothing pending"; break; }
  printf '\r    pending: %s  (%ds)' "$pending" "$((i*10))"
  sleep 10
done
echo

sqlite3 "file:$DB/history.sqlite?mode=ro" \
  "SELECT name, CASE is_not_synced WHEN 0 THEN 'synced' ELSE 'NOT SYNCED' END
   FROM history_table WHERE path LIKE '%mac-migration%' GROUP BY name;" 2>/dev/null \
  | sed 's/|/  ->  /' | sed 's/^/    /'

echo
echo "==> Done. $DEST"
ls -lh "$DEST" | tail -n +2 | awk '{printf "    %-26s %s\n", $9, $5}'
echo
echo "    Confirm in DSM that the files are on the NAS - local presence only"
echo "    proves they were queued. Quit Synology Drive before erasing this Mac:"
echo "    two-way sync would replicate the deletion."
