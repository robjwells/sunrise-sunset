from __future__ import annotations

import json

import pandas as pd
import pendulum


def parse_line(line: list[str]) -> tuple[int, str, str] | None:
    day, sunrise, sunset = line
    try:
        return (
            int(day),
            sunrise[:5],
            sunset[:5],
        )
    except ValueError:
        # DST note line or time disclaimer line.
        return None


def load_file(year, month):
    filename = f"sunrise-{year}-{month:02}.html"
    with open(filename) as f:
        data = f.read()
    return data


def data_to_table(data):
    t = pd.read_html(data, attrs={'id': 'as-monthsun'})[0]
    subset = t[t.keys()[:3]]
    return subset


def date_lines_from_table(table):
    lines = table.values
    maybe_parsed = [parse_line(line) for line in lines]
    return [parsed for parsed in maybe_parsed if parsed is not None]


def process_lines(year: int, month: int) -> list[tuple[int, str, str]]:
    data = load_file(year, month)
    table = data_to_table(data)
    lines = date_lines_from_table(table)
    return lines


def parse_date(
    year: int, month: int, day: int, time: str
) -> str:
    return pendulum.parse(
        f"{year}-{month:02}-{day:02}T{time}",
        tz="Europe/London",
    ).to_iso8601_string()


def dates_to_dict(day: str, sunrise: str, sunset: str) -> dict[str, str]:
    return {
        "day": day,
        "sunrise": sunrise,
        "sunset": sunset,
    }


def do_thing():
    for year in (2021, 2022):
        for month in range(1, 13):
            lines = process_lines(year, month)
            for line in lines:
                day, sunrise, sunset = line
                date_dict = dates_to_dict(
                    f"{year:02}-{month:02}-{day:02}",
                    parse_date(year, month, day, sunrise),
                    parse_date(year, month, day, sunset),
                )
                yield date_dict


def main():
    print(
        json.dumps(list(do_thing()))
    )


if __name__ == '__main__':
    main()
