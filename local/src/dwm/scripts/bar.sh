#!/bin/dash

interval=0
upd_str=""
black="#141617"
black_dark="#141617"
white="#d3c6aa"
white_dark="#859289"
grey="#343f44"
grey_dark="#2d353b"
green="#a7c080"
green_dark="#859258"
red="#e67e80"
red_dark="#b85557"
blue="#7fbbb3"
blue_dark="#55837d"
cyan="#83c092"
cyan_dark="#599169"
orange="#e69875"
orange_dark="#b36d4e"
yellow="#dbbc7e"
yellow_dark="#ad9155"
pink="#d699b6"
pink_dark="#a86e8b"

reset="^d^"

sep="^b${black}^ "
sep_col=" "

prev_idle=0
prev_total=0
cpu_out=""

pkg_updates() {
    count=$({ timeout 3600 xbps-install -un 2>/dev/null || true; } | wc -l)
    if [ "$count" -eq 0 ]; then
        printf "^c%s^󱋌 ^c%s^Update" "$green" "$white"
    else
        printf "^c%s^󰅢 %d To Update" "$red_dark" "$count"
    fi
}

cpu() {
    read -r _ u1 n1 s1 i1 w1 irq1 sirq1 st1 _ </proc/stat
    sleep 0.3
    read -r _ u2 n2 s2 i2 w2 irq2 sirq2 st2 _ </proc/stat
    idle1=$((i1 + w1))
    idle2=$((i2 + w2))
    total1=$((u1 + n1 + s1 + i1 + w1 + irq1 + sirq1 + st1))
    total2=$((u2 + n2 + s2 + i2 + w2 + irq2 + sirq2 + st2))
    diff_idle=$((idle2 - idle1))
    diff_total=$((total2 - total1))
    if [ "$diff_total" -gt 0 ]; then
        cpu_val=$(((100 * (diff_total - diff_idle)) / diff_total))
    else
        cpu_val=0
    fi
    local cpu_str="${cpu_val}%"
    printf "^c%s^^b%s^  ^c%s^^b%s^ %s" "$green_dark" "$grey_dark" "$white" "$black" "$cpu_str"
}

mem() {
    local total=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
    local avail=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
    local used_pct=$(((total - avail) * 100 / total))
    local mem_str="${used_pct}%"
    printf "^c%s^^b%s^  " "$red_dark" "$grey_dark"
    printf "^c%s^^b%s^ %s" "$white" "$black" "$mem_str"
}

wlan() {
    case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
    up) printf "^c%s^^b%s^ 󰤨 ^b%s^ ^c%s^Connected" "$black" "$blue" "$black" "$blue" ;;
    down) printf "^c%s^^b%s^ 󰤭 ^b%s^ ^c%s^Disconnected" "$black" "$blue" "$black" "$blue" ;;
    esac
}

clock() {
    printf "^c%s^^b%s^ 󱑆 " "$pink" "$grey_dark"
    printf "^c%s^^b%s^ %s " "$white" "$black" "$(date '+%d %b %H:%M')"
}

if [ -z "$DISPLAY" ]; then
    echo "Error: No hay una sesión de X11 activa."
    exit 1
fi

while true; do
    if [ "$interval" -eq 0 ]; then
        (
            upd=$(pkg_updates)
            echo "$upd" >/tmp/status_pkg.tmp
        ) &
        interval=3600
    fi

    upd_str=""

    if [ -f /tmp/status_pkg.tmp ]; then
        read -r upd_str </tmp/status_pkg.tmp
    fi

    pkg_out=""
    [ -n "$upd_str" ] && pkg_out="${sep}${upd_str}${sep_col}"
    cpu
    xsetroot -name " ${pkg_out}$(wlan)${sep}$(cpu)${sep}$(mem)${sep}$(clock)$reset" 2>/dev/null || break
    interval=$((interval - 1))
    sleep 1
done
