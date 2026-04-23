#!/usr/bin/env bash
# Claude Code status line: model, reasoning effort, and quota usage with
# an end-of-window pace projection (used% scaled by the fraction of the
# window elapsed). Receives session JSON on stdin;
# see https://code.claude.com/docs/en/statusline.md
main() {
    local model effort fh_used fh_proj fh_out fh_reset sd_used sd_proj sd_out sd_reset out
    # Unit-separator delimiter: bash `read` merges runs of IFS *whitespace*
    # (tab/space), which would collapse empty fields and shift columns.
    IFS=$'\x1f' read -r model effort fh_used fh_proj fh_out fh_reset sd_used sd_proj sd_out sd_reset < <(parse_input)
    out="\033[1m${model}\033[0m"
    [[ -n "$effort" ]] && out+=" \033[2m·\033[0m \033[36m${effort}\033[0m"
    [[ -n "$fh_used" ]] && out+=" \033[2m·\033[0m \033[2m5h\033[0m $(pct "$fh_used")$(proj "$fh_proj")"
    [[ -n "$fh_out" ]] && out+=" \033[31m⚠$(fmt_time "$fh_out")\033[0m"
    [[ -n "$fh_reset" ]] && out+=" \033[2m($(fmt_time "$fh_reset"))\033[0m"
    [[ -n "$sd_used" ]] && out+=" \033[2m·\033[0m \033[2mwk\033[0m $(pct "$sd_used")$(proj "$sd_proj")"
    [[ -n "$sd_out" ]] && out+=" \033[31m⚠$(fmt_time "$sd_out")\033[0m"
    [[ -n "$sd_reset" ]] && out+=" \033[2m($(fmt_time "$sd_reset"))\033[0m"
    printf '%b' "$out"
}

# Extract one \x1f-separated line: model, effort, then used%/projected%
# (and reset epoch for the 5h window). Effort and rate_limits fields are
# absent when unsupported (effort) or on API-key billing / before the first
# response (rate_limits); absent values become empty fields.
parse_input() {
    jq -r --argjson now "$(date +%s)" '
        def projected(w; len):
            if w.used_percentage == null or w.resets_at == null then null
            else ($now - (w.resets_at - len)) as $elapsed
            | if $elapsed <= 0 or $elapsed > len then null
              else w.used_percentage * len / $elapsed | round
              end
            end;
        def exhausted_at(w; len):
            if w.used_percentage == null or w.resets_at == null
               or w.used_percentage <= 0 then null
            else (w.resets_at - len) as $start
            | ($now - $start) as $elapsed
            | if $elapsed <= 0 or $elapsed > len then null
              else ($start + $elapsed * 100 / w.used_percentage | round) as $t
              # only meaningful if 100% is reached before the window resets
              | if $t <= w.resets_at then $t else null end
              end
            end;
        [ (.model.display_name // .model.id // "?"),
          (.effort.level // ""),
          (.rate_limits.five_hour.used_percentage // "" | if . == "" then . else round end),
          (projected(.rate_limits.five_hour // {}; 5*3600) // ""),
          (exhausted_at(.rate_limits.five_hour // {}; 5*3600) // ""),
          (.rate_limits.five_hour.resets_at // ""),
          (.rate_limits.seven_day.used_percentage // "" | if . == "" then . else round end),
          (projected(.rate_limits.seven_day // {}; 7*86400) // ""),
          (exhausted_at(.rate_limits.seven_day // {}; 7*86400) // ""),
          (.rate_limits.seven_day.resets_at // "")
        ] | join("\u001f")'
}

# Format an epoch as HH:MM, prefixed with the weekday when it's more than
# 24h away (weekly-window times usually land on another day).
fmt_time() {
    if (( $1 - $(date +%s) >= 86400 )); then
        date -d "@$1" '+%a %H:%M'
    else
        date -d "@$1" '+%H:%M'
    fi
}

# Colorize a 0-100 usage percentage: green <50, yellow <80, red >=80.
pct() {
    local color=32
    (( $1 >= 80 )) && color=31 || { (( $1 >= 50 )) && color=33; }
    printf '\033[%dm%d%%\033[0m' "$color" "$1"
}

# Render a projected end-of-window percentage as a dim "→N%" suffix, red
# when over 100; empty input (projection not computable) renders nothing.
proj() {
    [[ -z "$1" ]] && return
    if (( $1 >= 100 )); then
        printf '\033[2m→\033[0m\033[31m%d%%\033[0m' "$1"
    else
        printf '\033[2m→%d%%\033[0m' "$1"
    fi
}

main
