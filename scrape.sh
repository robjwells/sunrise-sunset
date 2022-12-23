seq 2023 2030 | while read year; do
    seq 1 12 | while read month; do
        curl --silent \
            "https://www.timeanddate.com/sun/uk/london?month=${month}&year=${year}" \
            > "sunrise-${year}-${month}.html"
    done
done
