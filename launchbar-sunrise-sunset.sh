#!/bin/sh

set -euo pipefail

DBFILE="/Users/robjwells/projects/sunrise-sunset/sunrise-sunset-times.db"

function query() {
	sqlite3 $DBFILE <<- EOF
		with basic as (
			select
				-- Sunrise and sunset times on the 24-hour clock.
				strftime('%H:%M', sunrise, 'localtime') as sunrise,
				strftime('%H:%M', sunset, 'localtime') as sunset,
				-- Is the sunrise/sunset in the past?
				strftime('%s', sunrise) - strftime('%s', 'now') <= 0 as sunrise_past,
				strftime('%s', sunset) - strftime('%s', 'now') <= 0 as sunset_past,
				-- Absolute difference from now to sunrise/sunset in seconds.
				abs(strftime('%s', sunrise) - strftime('%s', 'now')) as sunrise_diff,
				abs(strftime('%s', sunset) - strftime('%s', 'now')) as sunset_diff
			from
				london
			where
				date = date('now')
		),

		-- Format difference in seconds as hours/minutes.
		-- (Technically as times but it works as durations).
		string_times as (
			select
				sunrise,
				sunrise_past,
				strftime('%H', sunrise_diff, 'unixepoch') as sunrise_hours,
				strftime('%M', sunrise_diff, 'unixepoch') as sunrise_minutes,
				sunset,
				sunset_past,
				strftime('%H', sunset_diff, 'unixepoch') as sunset_hours,
				strftime('%M', sunset_diff, 'unixepoch') as sunset_minutes
			from
				basic
		),

		-- Convert the durations from strings into integers.
		durations as (
			select
				sunrise,
				sunrise_past,
				cast(sunrise_hours as integer) as sunrise_hours,
				cast(sunrise_minutes as integer) as sunrise_minutes,
				sunset,
				sunset_past,
				cast(sunset_hours as integer) as sunset_hours,
				cast(sunset_minutes as integer) as sunset_minutes
			from
				string_times
		),

		-- Format the durations into natural language, with pluralisation.
		-- Use the empty string if sunrise/sunset is 0 minutes distant.
		parts as (
			select
				sunrise,
				sunrise_past,
				case when sunrise_hours > 1 then
					sunrise_hours || ' hours '
				when sunrise_hours = 1 then
					sunrise_hours || ' hour '
				else
					''
				end as sunrise_hours,
				case when sunrise_minutes > 1 then
					sunrise_minutes || ' minutes '
				when sunrise_minutes = 1 then
					sunrise_minutes || ' minute '
				else
					''
				end as sunrise_minutes,
				sunset,
				sunset_past,
				case when sunset_hours > 1 then
					sunset_hours || ' hours '
				when sunset_hours = 1 then
					sunset_hours || ' hour '
				else
					''
				end as sunset_hours,
				case when sunset_minutes > 1 then
					sunset_minutes || ' minutes '
				when sunset_minutes = 1 then
					sunset_minutes || ' minute '
				else
					''
				end as sunset_minutes
			from
				durations
		),

		-- Combine the formatted hour/minute parts and trim any whitespace.
		formatted as (
			select
				sunrise,
				sunrise_past,
				trim(sunrise_hours || sunrise_minutes) as sunrise_formatted,
				sunset,
				sunset_past,
				trim(sunset_hours || sunset_minutes) as sunset_formatted
			from
				parts
		),

		-- Note whether sunrise/sunset is in the future or past, or now.
		relative as (
			select
				sunrise,
				case when sunrise_past and length(sunrise_formatted) then
					sunrise_formatted || ' ago'
				when not sunrise_past and length(sunrise_formatted) then
					'in ' || sunrise_formatted
				else
					'right now'
				end as sunrise_relative,
				sunset,
				case when sunset_past and length(sunset_formatted) then
					sunset_formatted || ' ago'
				when not sunset_past and length(sunset_formatted) then
					'in ' || sunset_formatted
				else
					'right now'
				end as sunset_relative
			from 
				formatted
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
			relative
		;
	EOF
}

query
