using Kanones, CitableParserBuilder
using CitableBase, CitableCorpus, CitableText
using Orthography, PolytonicGreek
using OrderedCollections, StatsBase

textsrc = joinpath(pwd(), "texts", "oeconomicus-filtered.cex")
corpus = fromcex(textsrc, CitableTextCorpus, FileReader)


struct Occurs
    str::AbstractString
    count::Int
end

function delimited(occurs::Occurs; delimiter = ",")
    string(occurs.str, delimiter, occurs.count)
end

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
    pplist = []
    i = 0
    for kvect in keys(verbhisto)
        i = i + 1
        if length(kvect) > 1
            println("MULTI: $(kvect)")
        end
        for vb in kvect 
            # Get counts...
            count = verbhisto[kvect]
            pps = join(principalparts(LexemeUrn(vb), kds), ", ")
            data = string(count, ",", pps)
            @info(string(i, "...", data))
            push!(pplist, Occurs(pps,count))
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


kroot = joinpath(pwd() |> dirname, "Kanones.jl")
pps_by_freqs = occursdata(corpus, kroot)

outstr = join(pps_by_freqs .|> delimited,"\n")

open("oec-princparts.csv","w") do io
    write(io, outstr)
end