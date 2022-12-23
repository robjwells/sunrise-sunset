from __future__ import annotations

import json
from pathlib import Path
from typing import Iterator

import pandas as pd  # type: ignore
from pendulum.parser import parse


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


def load_file(year: int, month: int) -> str:
    filename = f"sunrise-{year}-{month:02}.html"
    with open(filename) as f:
        data = f.read()
    return data


def data_to_table(data: str) -> pd.DataFrame:
    t = pd.read_html(data, attrs={"id": "as-monthsun"})[0]
    subset = t[t.keys()[:3]]
    return subset


def date_lines_from_table(table: pd.DataFrame) -> list[tuple[int, str, str]]:
    lines = table.values
    maybe_parsed = [parse_line(line) for line in lines]
    return [parsed for parsed in maybe_parsed if parsed is not None]


def load_lines(file_contents: str) -> list[tuple[int, str, str]]:
    table = data_to_table(file_contents)
    lines = date_lines_from_table(table)
    return lines


def parse_date(year: int, month: int, day: int, time: str) -> str:
    date = parse(
        f"{year}-{month:02}-{day:02}T{time}",
        tz="Europe/London",
    )
    return date.to_iso8601_string()  # type: ignore


def dates_to_dict(day: str, sunrise: str, sunset: str) -> dict[str, str]:
    return {
        "date": day,
        "sunrise": sunrise,
        "sunset": sunset,
    }


def date_data_to_dict(
    year: int, month: int, sun_info: tuple[int, str, str]
) -> dict[str, str]:
    day, sunrise, sunset = sun_info
    date_dict = dates_to_dict(
        f"{year:02}-{month:02}-{day:02}",
        parse_date(year, month, day, sunrise),
        parse_date(year, month, day, sunset),
    )
    return date_dict


def get_all_html() -> Iterator[dict[str, str]]:
    files = Path(".").glob("*.html")
    for f in files:
        year, month = [int(part) for part in f.stem.split("-")[-2:]]
        for sun_info in load_lines(f.read_text()):
            yield date_data_to_dict(year, month, sun_info)


def main() -> None:
    print(json.dumps(list(get_all_html())))


if __name__ == "__main__":
    main()
