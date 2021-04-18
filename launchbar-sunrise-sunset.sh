#!/bin/sh

set -euo pipefail

PATH="/usr/local/bin:$PATH"
DBFILE="/Users/robjwells/projects/sunrise-sunset/sunrise-sunset-times.db"

function query() {
	sqlite3 -cmd '.mode lines' $DBFILE <<- EOF
		select
			strftime('%H:%M', sunrise, 'localtime') as sunrise,
			strftime('%H:%M', sunset, 'localtime') as sunset
		from
			london
		where
			date = date('now')
		;
	EOF
}

function sunrise_end() {
	sd '(sunrise.+)$' '$1", "icon": "font-awesome:fa-sun-o"}'
}

function sunset_end() {
	sd '(sunset.+)$' '$1", "icon": "font-awesome:fa-moon-o"}'
}

function add_front() {
	sd '^\s*sun\w+ = ' '{"title": "'
}

function add_end() {
	sunrise_end | sunset_end
}

function format_object() {
	add_end | add_front
}

query | format_object | jq --slurp
