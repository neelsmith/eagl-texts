using Kanones, CitableParserBuilder
using CitableBase, CitableCorpus, CitableText
using Orthography, PolytonicGreek
using StatsBase, OrderedCollections


repo = pwd() # |> dirname  # root of eagl-texts repository
textsrc = joinpath(repo, "texts", "lysias1-filtered.cex")

corpus = fromcex(textsrc, CitableTextCorpus, FileReader)
tkncorpus = tokenize(corpus, literaryGreek())

lex = filter(tkncorpus) do t
    t.tokentype isa LexicalToken
end


kroot = joinpath(repo |> dirname, "Kanones.jl") # root of Kanones repository
parser = Kanones.coreparser(kroot; atticonly = true)

ktokens = map(lex) do l
    parsepassage(l, parser)
end


function infins(analyzedtkns)
	filter(analyzedtkns) do atkn
		if isempty(atkn.analyses)
			false
		else
			sampleform = atkn.analyses[1].form |> greekForm
			sampleform isa GMFInfinitive
		end
	end
end

lysinfins = infins(ktokens)

aorinfins = filter(lysinfins) do tkn
	#tkn.ctoken.passage.text	
	t = tkn.analyses[1] |> greekForm |> gmpTense
	t == gmpTense("aorist")
end

infincounts = map(lysinfins) do tkn
	tkn.analyses[1] |> greekForm |> gmpTense |> label
end |> countmap


#eg.ctoken.passage.text


formlist = map(lysinfins) do tkn
	tkn.ctoken.passage.text
end

open("lysinfins.txt","w") do io
	write(io, join(formlist, "\n"))
end


wordlist = readlines("lysinfins.txt")

sorted = PolytonicGreek.sortWords(wordlist, literaryGreek())

open("infins-sorted.txt", "w") do io
	write(io, join(unique(sorted),"\n"))
end