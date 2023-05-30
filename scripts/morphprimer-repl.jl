using Downloads
using CitableParserBuilder
using Orthography 
using PolytonicGreek
using CitableBase, CitableText, CitableCorpus
using Kanones

using StatsBase
using OrderedCollections
using DataFrames

using Plots
plotly()

# 1. Corpus
src = joinpath(pwd() |> dirname, "eagl-texts", "texts", "oeconomicus.cex")
corpus = fromcex(src, CitableTextCorpus, FileReader)

# 2. Citable tokens
lg = literaryGreek()
citabletokens = tokenize(corpus, lg)

# 3. Analyzed tokens
parsersrc = "/Users/nsmith/Dropbox/_kanones/literarygreek-all-2023-05-25.csv"
parser = dfParser(read(parsersrc))
analyzedtokens = parsecorpus(tokenizedcorpus(corpus,lg), parser)


# 4. Indexing tokens and lexemes
tokenindex = corpusindex(corpus, lg)
lexdict  = lexemedictionary(analyzedtokens.analyses, tokenindex)


# 5. Surveying morphology of a corpus
histo = corpus_histo(corpus, lg, filterby = LexicalToken())#, normalizer =  knormal)



# 6. Label lexemes
labeldict = Kanones.lsjdict()
labeldictx = Kanones.lsjxdict()