using Kanones, CitableParserBuilder
using CitableBase, CitableCorpus, CitableText, CitableCollection, CitableObject
using Orthography, PolytonicGreek
using OrderedCollections, StatsBase

repo = pwd() # root of eagl-texts repository
kroot = joinpath(repo |> dirname, "Kanones.jl") # root of Kanones repository

textsrc = joinpath(repo, "texts", "lysias1-filtered.cex")
outfile = joinpath(repo, "lysias1-princparts.csv")
corpus = fromcex(textsrc, CitableTextCorpus, FileReader)


struct Occurs
    label::AbstractString
    count::Int
    data::AbstractString
end

function delimited(occurs::Occurs; delimiter = ",")
    string(occurs.label, delimiter, occurs.count, delimiter, occurs.data)
end


LSJ_FU_URL = "https://raw.githubusercontent.com/Eumaeus/cite_lsj_cex/master/lsj_chicago.cex"
"""Read CITE Collection from CEX source."""
function lsjcollection()
	collv = fromcex(LSJ_FU_URL, CatalogedCollection, UrlReader; delimiter = "#")
	collv[2]
end
lsjdata = lsjcollection()


"""Filter a vector of `AnalzedToken`s to keep only nouns."""
function verbsonly(analyzedtkns)
	filter(analyzedtkns) do atkn
		if isempty(atkn.analyses)
			false
		else
			sampleform = atkn.analyses[1].form |> greekForm
			sampleform isa GMFNoun
		end
	end
end
