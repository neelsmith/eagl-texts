using CitableBase, CitableCorpus
using Orthography, PolytonicGreek


srcf = joinpath(pwd(), "texts", "iliad-allen.cex")

c = fromcex(srcf, CitableTextCorpus, FileReader)

hist = corpus_histo(c, literaryGreek())

hist |> length

function topn(histo, n)
    filter(pr -> pr[2] >= n, histo)
end

function listp(v)
    println(join(v, "\n"))
end



topn(hist,10) |> listp