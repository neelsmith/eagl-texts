using CitableBase, CitableText, CitableCorpus
using Orthography, PolytonicGreek
using Kanones

xenfile = joinpath(pwd(), "texts", "oeconomicus-filtered.cex")
lysfile = joinpath(pwd(), "texts", "lysias1-filtered.cex")


xencorp = fromcex(xenfile, CitableTextCorpus, FileReader)
xenhist = corpus_histo(xencorp, literaryGreek(), filterby = LexicalToken(), normalizer = knormal)

lyscorp = fromcex(lysfile, CitableTextCorpus, FileReader)
lyshist = corpus_histo(lyscorp, literaryGreek(), filterby = LexicalToken(), normalizer = knormal)

c = vcat(lyscorp.passages, xencorp.passages) |> CitableTextCorpus
hist = corpus_histo(c, literaryGreek(), filterby = LexicalToken(), normalizer = knormal)
