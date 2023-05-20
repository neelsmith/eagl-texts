using CitableBase, CitableText, CitableCorpus
using Orthography, PolytonicGreek


xenfile = joinpath(pwd(), "texts", "oeconomicus.cex")
lysfile = joinpath(pwd(), "texts", "lysias1.cex")

xencorp = fromcex(xenfile, CitableTextCorpus, FileReader)
xenhist = corpus_histo(xencorp, literaryGreek(), filterby = LexicalToken())

lyscorp = fromcex(lysfile, CitableTextCorpus, FileReader)
lyshist = corpus_histo(lyscorp, literaryGreek(), filterby = LexicalToken())

c = vcat(lyscorp.passages, xencorp.passages) |> CitableTextCorpus
hist = corpus_histo(c, literaryGreek(), filterby = LexicalToken())
