using GreekBetaCode

"""Read CEX source file `textname.cex`,
roundtrip U->B->U to get cleaner Unicode greek,
write results to `textname-filtered.cex`.
Return name of output file.
"""
function purifyortho(textname)
    txtfile = joinpath(pwd(), "texts", "$(textname).cex")
    lines = readlines(txtfile)
    totallines = length(lines)
    corrected = []
    for (idx, ln) in enumerate(lines)
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

    outfile = joinpath(pwd(), "texts", "$(textname)-filtered.cex")
    open(outfile, "w") do io
        write(io, join(corrected,"\n"))
    end
    outfile
end

# Clean up a text, test reading back as a corpus:
tidier = purifyortho("apollodorus")

using CitableBase, CitableCorpus
c = fromcex(tidier, CitableTextCorpus, FileReader)
