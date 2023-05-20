using CitableBase, CitableText, CitableCorpus
using Orthography, PolytonicGreek


xenfile = joinpath(pwd(), "texts", "oeconomicus.cex")
lysfile = joinpath(pwd(), "texts", "lysias1.cex")

xencorp = fromcex(xenfile, CitableTextCorpus, FileReader)
lyscorp = fromcex(lysfile, CitableTextCorpus, FileReader)


c = vcat(lyscorp.passages, xencorp.passages) |> CitableTextCorpus

hist = corpus_histo(c, literaryGreek(), filterby = LexicalToken())
