using CitableBase, CitableText, CitableCorpus


txtfile = joinpath(pwd(), "texts", "iliad-allen-filtered.cex")
c = fromcex(txtfile, CitableTextCorpus, FileReader)

bk6 = filter(c.passages) do psg 
    startswith(passagecomponent(urn(psg)), "6.")
end |> CitableTextCorpus

outfile = joinpath(pwd(), "texts", "iliad-allen-bk6-filtered.cex")
open(outfile, "w") do io
    write(io, cex(bk6))
end