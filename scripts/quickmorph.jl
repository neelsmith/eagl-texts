using Kanones
using CitableParserBuilder
using Downloads

parsersrc = "https://raw.githubusercontent.com/neelsmith/Kanones.jl/dev/parsers/current-core.csv"

parser = dfParser(Downloads.download(parsersrc))