using Kanones
using CitableBase, CitableCorpus, CitableText
using Orthography, PolytonicGreek
using OrderedCollections, StatsBase

textsrc = joinpath(pwd(), "texts", "lysias1.cex")
corpus = fromcex(textsrc, CitableTextCorpus, FileReader)

kroot = joinpath(pwd() |> dirname, "Kanones.jl")
parsersrc = joinpath(kroot, "parsers", "current-core-attic.csv")
parser = dfParser(parsersrc)


lg = literaryGreek()
analyzedtokencollection = parsecorpus(tokenizedcorpus(corpus,lg, filterby = LexicalToken()), parser)

dict = Kanones.lsjdict()


#=
function lexemestrings(atkn, dict = dict)
    map(atkn.analyses .|> Kanones.lexemeurn) do a
       lemmalabel(a, dict = dict) 
    end |> unique
end
=#


function verbsonly(analyzedtkns)
	filter(analyzedtkns) do atkn
		if isempty(atkn.analyses)
			false
		else
			sampleform = atkn.analyses[1].form |> greekForm
			sampleform isa GMFFiniteVerb || 
			sampleform isa GMFInfinitive || 
			sampleform isa GMFParticiple || 
			sampleform isa GMFVerbalAdjective
		end
	end
end


verbs = verbsonly(analyzedtokencollection.analyses)
labelledlexemelist = verbs .|> lexemestrings |> Iterators.flatten |>  collect
filter(labelledlexemelist) do l
    startswith(l, "lsj.842")
end
matchme = filter(labelledlexemelist) do l
    startswith(l, "lsj.n2429")
end |> unique
join(matchme, ", ")

lexemelist = map(verbs) do v
    map(a -> string(Kanones.lexemeurn(a)), v.analyses) |> unique
end
verbhisto = sort!(OrderedDict(countmap(lexemelist)); byvalue = true, rev = true)




ds = Kanones.coredata(kroot; atticonly = true)
pplist = []
for kvect in keys(verbhisto)
    if length(kvect) > 1
        println("MULTI: $(kvect)")
    end
    #for vb in verbhisto[k]
    # push!(pplist, principalparts(k, ds))
    #end
end