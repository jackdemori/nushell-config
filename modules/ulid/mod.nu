const ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

# Encode an integer as a fixed-width Crockford base32 string
def base32-encode [width: int]: int -> string {
    let chars = ($ALPHABET | split chars)
    mut result = []
    mut val = $in
    for _i in 0..<$width {
        let idx = ($val mod 32 | into int)
        $result = ($result | append ($chars | get $idx))
        $val = (($val - $idx) / 32 | into int)
    }
    $result | reverse | str join
}

# Decode a Crockford base32 string to an integer
def base32-decode []: string -> int {
    let input = ($in | str upcase
        | str replace --all 'I' '1'
        | str replace --all 'L' '1'
        | str replace --all 'O' '0')
    mut result = 0
    for c in ($input | split chars) {
        let idx = ($ALPHABET | str index-of $c)
        if $idx < 0 {
            error make { msg: $"Invalid Crockford base32 character: ($c)" }
        }
        $result = $result * 32 + $idx
    }
    $result
}

# Generate a random ULID (Universally Unique Lexicographically Sortable Identifier).
#
# A ULID is a 26-character string encoding a 48-bit timestamp (milliseconds)
# and an 80-bit random component using Crockford base32.
#
# Examples:
#   Generate a ULID with the current timestamp
#   > random ulid
#
#   Generate a ULID from a specific datetime
#   > '2025-01-15T12:30:00+00:00' | into datetime | random ulid
#
#   Generate a ULID with zeroed random portion (useful as a lower sort bound)
#   > random ulid --zeroed
#
#   Generate a ULID with maxed random portion (useful as an upper sort bound)
#   > random ulid --oned
export def "random ulid" [
    --zeroed(-z)  # Fill random portion with zeros
    --oned(-o)    # Fill random portion with ones
]: [nothing -> string, datetime -> string] {
    if $zeroed and $oned {
        error make { msg: "Cannot use both --zeroed and --oned" }
    }

    let input = $in
    let ts = if ($input | describe) == "datetime" { $input } else { date now }

    let epoch = ('1970-01-01T00:00:00+00:00' | into datetime)
    let ts_ms = ((($ts - $epoch) | into int) / 1_000_000 | into int)

    let ts_encoded = ($ts_ms | base32-encode 10)

    let max_40 = 1099511627775 # 2^40 - 1
    let rnd_hi = if $zeroed { 0 } else if $oned { $max_40 } else { random int 0..$max_40 }
    let rnd_lo = if $zeroed { 0 } else if $oned { $max_40 } else { random int 0..$max_40 }

    let rnd_encoded = ($rnd_hi | base32-encode 8) + ($rnd_lo | base32-encode 8)

    $ts_encoded + $rnd_encoded
}

# Parse a ULID string into its timestamp and random components.
#
# Returns a record with `timestamp` (datetime) and `random` (base32 string).
#
# Examples:
#   Parse a ULID to extract its timestamp
#   > '01JHMZ2AA00000000000000000' | parse ulid | get timestamp
#
#   Generate and immediately parse a ULID
#   > random ulid | parse ulid
export def "parse ulid" []: string -> record {
    let input = ($in | str trim | str upcase)

    if ($input | str length) != 26 {
        error make { msg: $"Invalid ULID: expected 26 characters, got ($input | str length)" }
    }

    let ts_part = ($input | str substring 0..<10)
    let rnd_part = ($input | str substring 10..<26)

    let ts_ms = ($ts_part | base32-decode)

    let epoch = ('1970-01-01T00:00:00+00:00' | into datetime)
    let timestamp = $epoch + ($ts_ms * 1_000_000 * 1ns)

    {
        timestamp: $timestamp
        random: $rnd_part
    }
}
