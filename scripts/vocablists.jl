#=
Generate vocabulary lists covering top n pct of a corpus, and break out by part of speech.
=#
using Kanones
using CitableBase, CitableText, CitableCorpus
using PolytonicGreek, Orthography
using StatsBase, OrderedCollections

# Set threshhold of text to cover as a percent:
threshhold = 0.75

# Load parser from a local file:
kroot = joinpath(pwd() |> dirname, "Kanones.jl")
parsersrc = joinpath(kroot, "parsers", "current-core-attic.csv")
parser = dfParser(parsersrc)

# Load corpus to analyze
txtsrc = joinpath(pwd(), "texts", "lysias1-filtered.cex")
corpus = fromcex(txtsrc, CitableTextCorpus, FileReader)

# Tokenize corpus and analyze:
ortho = literaryGreek()
tcorpus = tokenizedcorpus(corpus, ortho, filterby = LexicalToken())
analyzedlexical = parsecorpus(tcorpus, parser)
successes = filter(tkn -> 	! isempty(tkn.analyses), analyzedlexical.analyses)
uniqueanalyses = map(tkn -> tkn.analyses[1], successes) |> unique

# Count frequenecies for each each lexeme
#successcounts = map(tkn -> tkn.ctoken.passage.text, successes) |> countmap |> OrderedDict
lexemecounts = map(tkn -> string(tkn.analyses[1].lexeme), successes) |> countmap |> OrderedDict
sort!(lexemecounts; byvalue = true, rev = true)
orderedlexkeys = keys(lexemecounts) |> collect

# Find running totals and running pct covered  for each lexeme,
# filter for vocab items covering the minimum threshhold:
lexemetallies = Int[]
for k in orderedlexkeys
    currtotal = lexemecounts[k]
    if isempty(lexemetallies)
        push!(lexemetallies, currtotal) 
    else
        prevtotal = lexemetallies[end]
        push!(lexemetallies, (currtotal + prevtotal) )
    end
end
runninglexpcts = lexemetallies ./ length(analyzedlexical)
coveragelist = filter(pct -> pct < threshhold, runninglexpcts)


# Labelling...
lemmalabels = Kanones.lemmatadict()


s# We want to find one example of an analysis for a given lexeme
# Not yet published in Kanones?
# q&d version:
function labellexid(lexurn, labeldict)
    idval = split(string(lexurn), ".")[2]
    string(labeldict[idval], " (", idval, ")")
end

# Look at type of GreekForm in the analysis to "part of speech"
function posForAnalysis(analyzed)
    analyzedform = analyzed |> formurn |> greekForm

    if analyzedform isa GMFUninflected
        @info("It's uninflected")
        analyzedform.pos |> label        
    else
        @info("it's inflected")
        label(analyzedform)
    end
end

resultsdict = Dict(
		"verb" => [],
		"noun" => [],
		"pronoun" => [],
		"preposition" => [],
        "conjunction" => []
		
)


samplelex = orderedlexkeys[2]
samplelabel = labellexid(samplelex, lemmalabels)
sampletotal = coveragelist[2]



uniqueanalyses[2].lexeme
samplelex

firstmatch = filter(morphanl -> string(morphanl.lexeme) == samplelex,  uniqueanalyses)[1]


firstmatch  |> posForAnalysis