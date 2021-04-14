# sunrise-sunset

A basic SQLite database containing the sunrise and sunset times for
London in 2021 and 2022. As well, there is a JSON file containing the
data, a SQL script to create the tables, and SQL queries to check
whether the sun has risen or set, and record a successful check for each
event per day.

I originally created this as the automatic light/dark mode switching on
macOS was often kicking in long after sunset, so I wrote a Keyboard
Maestro macro to check the database during potential sunrise and sunset
hours, and set the system light/dark mode setting as appropriate.

The "successful checks" table is used as a guard so that the light/dark
mode is only switched once per event per day. This means that it won't
override any manual change you make after eg it switches because the sun
has risen.
