# COSMIC stores suspend timeouts in milliseconds. Follow the system timezone.
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/cosmic/com.system76.CosmicIdle/v1"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/cosmic-suspend-schedule"
mkdir -p "$config_dir" "$state_dir"

# Remember the daytime preference before applying the overnight override.
# An absent setting uses COSMIC's default of 15 minutes.
daytime_screen_setting="$state_dir/daytime-screen-off-time"
if [[ ! -f "$daytime_screen_setting" ]]; then
  daytime_screen_timeout='Some(900000)'
  if [[ -f "$config_dir/screen_off_time" ]]; then
    daytime_screen_timeout=$(cat "$config_dir/screen_off_time")
  fi
  temporary=$(mktemp "$state_dir/.daytime-screen-off-time.XXXXXX")
  printf '%s\n' "$daytime_screen_timeout" > "$temporary"
  mv -f "$temporary" "$daytime_screen_setting"
fi

hour=$(date +%H)
if (( 10#$hour >= 8 && 10#$hour < 18 )); then
  timeout=None
  screen_timeout=$(cat "$daytime_screen_setting")
else
  timeout='Some(600000)'
  screen_timeout='Some(300000)'
fi

for key in suspend_on_ac_time suspend_on_battery_time screen_off_time; do
  value=$timeout
  if [[ "$key" == screen_off_time ]]; then
    value=$screen_timeout
  fi
  setting="$config_dir/$key"
  # Avoid resetting COSMIC's idle notifications when the schedule is unchanged.
  if [[ -f "$setting" && $(cat "$setting") == "$value" ]]; then
    continue
  fi
  temporary=$(mktemp "$config_dir/.$key.XXXXXX")
  printf '%s\n' "$value" > "$temporary"
  mv -f "$temporary" "$setting"
done
