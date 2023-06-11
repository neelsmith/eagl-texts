using GreekBetaCode

hfile = joinpath(pwd(), "texts", "herodotus.cex")
hlines = readlines(hfile)
totallines = length(hlines)
corrected = []
for (idx, ln) in enumerate(hlines)

    if idx % 10 == 0
        @info("$(idx)/$(totallines)... ")
    end
    parts = split(ln, "|")
    if length(parts) == 2
        modified = string(parts[1], "|", U(B(string(parts[2]))))
        push!(corrected, modified)
    else
        push!(corrected, ln)
    end
end

outfile = joinpath(pwd(), "texts", "herodotus-filtered.cex")
open(outfile, "w") do io
    write(io, join(corrected,"\n"))
end

using CitableBase, CitableCorpus
c = fromcex(outfile, CitableTextCorpus, FileReader)
