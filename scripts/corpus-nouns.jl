using Kanones, CitableParserBuilder
using CitableBase, CitableCorpus, CitableText, CitableCollection, CitableObject
using Orthography, PolytonicGreek
using OrderedCollections, StatsBase

repo = pwd() # root of eagl-texts repository
kroot = joinpath(repo |> dirname, "Kanones.jl") # root of Kanones repository

textsrc = joinpath(repo, "texts", "lysias1-filtered.cex")
outfile = joinpath(repo, "lysias1-nouns.csv")
corpus = fromcex(textsrc, CitableTextCorpus, FileReader)
ortho = literaryGreek()


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
	classdict =  Kanones.Kanones.lexemetoclassdict(kds)
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
			entry = ""
			try 
				entry = lexicon_noun_md(LexemeUrn(noun), kds)
			catch e
				entry = "NO GENDER for $(noun)"
			end
			idval = split(noun, ".")[2]
			lsjrows = filter(lsjdata.data.data) do r
				objectcomponent(r.urn) == idval
			end
			labelstr = isempty(lsjrows) ? idval : lsjrows.key[1]
			lsjkey = string(idval,"@", labelstr)
			@info(string(i, "/", length(nounhisto),  "...", entry, " from ", lsjkey))

			hdrval = haskey(classdict, noun) ? string(lsjkey, " ", classdict[noun]) : string(lsjkey, " (no entry in dictionary for $(idval))")
			push!(entries, Occurs(hdrval, count, entry))
		
		end
	end
	entries
end

"""Given a text corpus and a clone of the Kanones repo, build an occurence structure
with principal parts of verbs, sorted by frequency of verb."""
function occursdata(corpus::CitableTextCorpus, kroot; ortho = literaryGreek(), dict = Kanones.lsjdict())
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
end



lexicon = occursdata(corpus, kroot)


outstr = join(lexicon .|> delimited,"\n")
open(outfile,"w") do io
    write(io, outstr)
end
println("Wrote results to file $(outfile)")
