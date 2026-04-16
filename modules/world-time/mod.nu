use ../ui [step done clear-status]

const CACHE_FILE = "time-now-zones.json"
const DAYS = [Sunday Monday Tuesday Wednesday Thursday Friday Saturday]

# Fetch and cache the list of IANA timezones from the Time.now API.
def get-timezone-list [--force-refresh]: nothing -> list<string> {
    let cache_file = $"($nu.cache-dir)/($CACHE_FILE)"

    if not $force_refresh and ($cache_file | path exists) {
        let age = (date now) - (ls $cache_file | get modified | first)
        if $age < 180day {
            return (try { open $cache_file } catch { [] })
        }
    }

    step --tick 0 "Fetching IANA timezone list"
    let zones = try {
        http get --max-time 10sec https://time.now/developer/api/timezone
    } catch {
        clear-status
        if ($cache_file | path exists) {
            return (open $cache_file)
        }
        error make { msg: "Cannot fetch timezone list and no cache available." }
    }

    try { $zones | save --force $cache_file }
    clear-status
    $zones
}

# Score and rank timezone matches for a query.
def find-timezone [query: string, zones: list<string>]: nothing -> string {
    let query_lower = ($query | str downcase)
    let escaped = ($query | str replace --all --regex '([\[\]()*+?^$.|\\])' '\$1')

    # Exact match
    let exact = $zones | where $it =~ ('(?i)^' + $escaped + '$')
    if ($exact | is-not-empty) {
        return ($exact | first)
    }

    # Fuzzy match
    let fuzzy_pattern = ($query | split chars | where $it != ""
        | each {|c| $c | str replace --all --regex '([\[\]()*+?^$.|\\])' '\$1'}
        | str join ".*")

    let scored = $zones | each {|z|
        let full_dist = ($z | str downcase | str distance $query_lower)
        let loc_name = ($z | split row / | last | str downcase)
        let loc_dist = ($loc_name | str distance $query_lower)
        let min_dist = [($full_dist) ($loc_dist)] | math min

        let is_loc_prefix = ($loc_name | str starts-with $query_lower)
        let is_substring = ($z =~ ('(?i)' + $escaped))
        let is_subseq = ($z =~ ('(?i)' + $fuzzy_pattern))

        let final_dist = if $is_loc_prefix {
            $min_dist - 300
        } else if $is_substring {
            $min_dist - 200
        } else if $is_subseq {
            $min_dist - 100
        } else {
            $min_dist
        }

        { zone: $z, dist: $final_dist }
    } | sort-by dist

    let best = $scored | first
    let max_dist = (($query | str length) / 2 | math floor) + 2

    if $best.dist > $max_dist {
        error make { msg: $"No timezone found matching '($query)'" }
    }

    $best.zone
}

# Fetch the current time data for a timezone from the Time.now API.
def fetch-timezone-time [timezone: string]: nothing -> record {
    try {
        http get --max-time 5sec $"https://time.now/developer/api/timezone/($timezone)"
    } catch {
        error make { msg: $"Failed to fetch time for ($timezone)" }
    }
}

# Look up the current time in one or more timezones using the Time.now API.
#
# Returns a table with timezone, time, date, day, UTC offset, and DST status.
# Uses fuzzy matching so you can type city names instead of full IANA identifiers.
#
# Examples:
#   Look up a single timezone
#   > world-time tokyo
#
#   Look up multiple timezones at once
#   > world-time tokyo london sydney
#
#   List all available timezones
#   > world-time --list
#
#   Force refresh the cached timezone list
#   > world-time --force-cache tokyo
#
#   Return all fields from the API
#   > world-time --all tokyo
export def main [
    ...queries: string              # City, region, or IANA timezone (e.g., "tokyo", "Europe/Paris")
    --force-cache (-f)              # Force refresh of cached timezone list
    --list (-l)                     # List all available timezones
    --all (-a)                      # Return all fields from the API
]: nothing -> table {
    if $list {
        let zones = get-timezone-list --force-refresh=$force_cache
        return ($zones | wrap timezone)
    }

    let queries = if ($queries | is-empty) {
        # Default to the system's local timezone
        let local_tz = (ls -l /etc/localtime | get target.0 | str replace --regex '.*/zoneinfo/' '')
        [$local_tz]
    } else {
        $queries
    }

    let zones = get-timezone-list --force-refresh=$force_cache

    let result = ($queries | enumerate | each {|it|
        let query = $it.item
        step --tick ($it.index + 1) $"Fetching time for (ansi cyan)($query)(ansi reset)"
        let matched = find-timezone $query $zones
        let data = fetch-timezone-time $matched

        if $all {
            return $data
        }

        let tz = ($data.timezone? | default "Unknown")
        let abbr = ($data.abbreviation? | default "")
        let dt = ($data.datetime? | default "" | into datetime)
        let offset = ($data.utc_offset? | default "+00:00")
        let dst = ($data.dst? | default false)
        let day_num = ($data.day_of_week? | default 0)
        let week = ($data.week_number? | default 0)

        {
            timezone: $"($tz) \(($abbr)\)"
            time: ($dt | format date '%H:%M:%S')
            date: ($dt | format date '%Y-%m-%d')
            day: ($DAYS | get $day_num)
            week: $week
            utc_offset: $offset
            dst: $dst
        }
    })

    clear-status
    $result
}
