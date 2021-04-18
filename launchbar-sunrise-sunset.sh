#!/bin/sh

set -euo pipefail

DBFILE="/Users/robjwells/projects/sunrise-sunset/sunrise-sunset-times.db"

function query() {
	sqlite3 $DBFILE <<- EOF
		with basic as (
			select
				strftime('%H:%M', sunrise, 'localtime') as sunrise,
				strftime('%H:%M', sunset, 'localtime') as sunset,
				strftime('%s', sunrise) - strftime('%s', 'now') <= 0 as sunrise_past,
				strftime('%s', sunset) - strftime('%s', 'now') <= 0 as sunset_past,
				abs(strftime('%s', sunrise) - strftime('%s', 'now')) as sunrise_diff,
				abs(strftime('%s', sunset) - strftime('%s', 'now')) as sunset_diff
			from
				london
			where
				date = date('now')
		),
		parts as (
			select
				*,
				ltrim(strftime('%H', sunrise_diff, 'unixepoch'), '0') as sunrise_hours,
				ltrim(strftime('%M', sunrise_diff, 'unixepoch'), '0') as sunrise_minutes,
				ltrim(strftime('%H', sunset_diff, 'unixepoch'), '0') as sunset_hours,
				ltrim(strftime('%M', sunset_diff, 'unixepoch'), '0') as sunset_minutes
			from
				basic
		),
		formatted as (
			select
				*,
				sunrise_hours || ' hours ' || sunrise_minutes || ' minutes' as sunrise_formatted,
				sunset_hours || ' hours ' || sunset_minutes || ' minutes' as sunset_formatted
			from
				parts
		),
		relative as (
			select
				*,
				case when sunrise_past then
					sunrise_formatted || ' ago'
				else
					'in ' || sunrise_formatted
				end as sunrise_relative,
				case when sunset_past then
					sunset_formatted || ' ago'
				else
					'in ' || sunset_formatted
				end as sunset_relative
			from 
				formatted
		), processed as (
			select
				sunrise,
				sunrise_relative,
				sunset,
				sunset_relative
			from
				relative
		)
		select
			json_array(
				json_object(
					'title', sunrise_relative,
					'badge', sunrise,
					'icon', 'font-awesome:fa-sun-o'
				),
				json_object(
					'title', sunset_relative,
					'badge', sunset,
					'icon', 'font-awesome:fa-moon-o'
				)
			) as launchbar_items
		from
			processed
		;
	EOF
}

query
