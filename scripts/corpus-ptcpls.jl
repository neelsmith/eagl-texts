using Kanones, CitableParserBuilder
using CitableBase, CitableCorpus, CitableText, CitableCollection, CitableObject
using Orthography, PolytonicGreek
using OrderedCollections, StatsBase


repo = pwd() # |> dirname  # root of eagl-texts repository
textsrc = joinpath(repo, "texts", "oeconomicus-filtered.cex")

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

function ptcplsonly(analyzedtkns)
	filter(analyzedtkns) do atkn
		if isempty(atkn.analyses)
			false
		else
			sampleform = atkn.analyses[1].form |> greekForm
			sampleform isa GMFParticiple
		end
	end
end

ptcpls = ptcplsonly(ktokens)

ptcpls[1]

cexlines = map(p  -> cex(p), ptcpls)

open("ptcpls.cex", "w") do io
    write(io, join(cexlines, "\n"))
end