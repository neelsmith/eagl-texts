using Kanones, CitableParserBuilder
using CitableBase, CitableCorpus, CitableText, CitableCollection, CitableObject
using Orthography, PolytonicGreek
using OrderedCollections, StatsBase

repo = pwd() # root of eagl-texts repository
kroot = joinpath(repo |> dirname, "Kanones.jl") # root of Kanones repository

textsrc = joinpath(repo, "texts", "oeconomicus-filtered.cex")
outfile = joinpath(repo, "xen-oec-princparts.csv")
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

"""Filter a vector of `AnalzedToken`s to keep only verbs."""
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


"""List principal of verbs sorted by frequency of verbs in corpus."""
function verb_pps_by_freq(verbhisto::OrderedDict{Vector{String}, Int64}, kds::Kanones.FilesDataset)
    classdict =  Kanones.Kanones.lexemetoclassdict(kds)

    pplist = []
    i = 0
    for kvect in keys(verbhisto)
        i = i + 1
        if length(kvect) > 1
            println("Multiple IDs: $(kvect)")
        end

        for vb in kvect 
            # Get counts...
            count = verbhisto[kvect]
            pps = join(principalparts(LexemeUrn(vb), kds), ", ")

            idval = split(vb, ".")[2]
            lsjrows = filter(lsjdata.data.data) do r
                objectcomponent(r.urn) == idval
            end
            data = string(count, ",", pps)
            
            lsjkey = isempty(lsjrows) ? string(idval,"@","nolemma") : string(idval,"@", lsjrows.key[1])
            @info(string(i, "/", length(verbhisto),  "...", data, " from ", lsjkey))

            hdrval = haskey(classdict, vb) ? string(lsjkey, " ", classdict[vb]) : string(lsjkey, " (no entry in dictionary for $(idval))")
            push!(pplist, Occurs(string(lsjkey, " ", hdrval), count, pps))
        end
    end
    pplist
end

"""Given a text corpus and a clone of the Kanones repo, build an occurence structure
with principal parts of verbs, sorted by frequency of verb."""
function occursdata(c::CitableTextCorpus, krepo; ortho = literaryGreek(), dict = Kanones.lsjdict())
    parsersrc = joinpath(kroot, "parsers", "current-core-attic.csv")
    parser = dfParser(parsersrc)
    analyzedtokencollection = parsecorpus(tokenizedcorpus(corpus,ortho, filterby = LexicalToken()), parser)

    verbs = verbsonly(analyzedtokencollection.analyses)
    lexemelist = map(verbs) do v
        map(a -> string(Kanones.lexemeurn(a)), v.analyses) |> unique
    end
    verbhisto = sort!(OrderedDict(countmap(lexemelist)); byvalue = true, rev = true)

    ds = Kanones.coredata(kroot; atticonly = true)
    verb_pps_by_freq(verbhisto, ds)
end



pps_by_freqs = occursdata(corpus, kroot)


outstr = join(pps_by_freqs .|> delimited,"\n")
open(outfile,"w") do io
    write(io, outstr)
end
println("Wrote results to file $(outfile)")
