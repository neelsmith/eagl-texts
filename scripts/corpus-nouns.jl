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
function nounsonly(analyzedtkns)
	filter(analyzedtkns) do atkn
		if isempty(atkn.analyses)
			false
		else
			sampleform = atkn.analyses[1].form |> greekForm
			sampleform isa GMFNoun
		end
	end
end

function nounlexbyfreq(nounhisto::OrderedDict{Vector{String}, Int64}, kds::Kanones.FilesDataset)
	nounhisto
end

ortho = literaryGreek()

"""Given a text corpus and a clone of the Kanones repo, build an occurence structure
with principal parts of verbs, sorted by frequency of verb."""
#function occursdata(corpus::CitableTextCorpus, kroot; ortho = literaryGreek(), dict = Kanones.lsjdict())
    parsersrc = joinpath(kroot, "parsers", "current-core-attic.csv")
    parser = dfParser(parsersrc)
    analyzedtokencollection = parsecorpus(tokenizedcorpus(corpus,ortho, filterby = LexicalToken()), parser)

    nouns = nounsonly(analyzedtokencollection.analyses)
    lexemelist = map(nouns) do noun
        map(a -> string(Kanones.lexemeurn(a)), noun.analyses) |> unique
    end
    nounhisto = sort!(OrderedDict(countmap(lexemelist)); byvalue = true, rev = true)

    ds = Kanones.coredata(kroot; atticonly = true)
    nounlexbyfreq(nounhisto, ds)
#end



entries = []
i = 0

for kvect in keys(nounhisto)
	i = i + 1
	if length(kvect) > 1
		println("Multiple IDs: $(kvect)")
	end

	for noun in kvect 
		# Get counts...
		count = nounhisto[kvect]
		#pps = #join(principalparts(LexemeUrn(vb), kds), ", ")
		entry = lexicon_noun_md(LexemeUrn(noun), ds)
		push!(entries, entry)
#=
		idval = split(vb, ".")[2]
		lsjrows = filter(lsjdata.data.data) do r
			objectcomponent(r.urn) == idval
		end
		data = string(count, ",", pps)
		lsjkey = string(idval,"@", lsjrows.key[1])
		@info(string(i, "/", length(verbhisto),  "...", data, " from ", lsjkey))
		push!(pplist, Occurs(lsjkey, count, pps))
		=#
	end
end
pplist