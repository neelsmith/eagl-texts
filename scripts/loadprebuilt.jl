using CSV, DataFrames
using Orthography, PolytonicGreek
using CitableBase, CitableCorpus
using CitableParserBuilder
using Kanones
using StatsBase, OrderedCollections

kroot = joinpath(dirname(pwd()), "Kanones.jl")
parsersrc = joinpath(kroot, "parsers", "current-core-attic.csv")

dfparser = dfParser(parsersrc)


eaglbase = joinpath(pwd() |> dirname, "eagl-texts")
f = joinpath(eaglbase, "texts", "lysias1-filtered.cex") 
isfile(f)
corpus = fromcex(f, CitableTextCorpus, FileReader)

lg = literaryGreek()
histo =  corpus_histo(corpus, lg, filterby = LexicalToken())
lexcorpus = tokenizedcorpus(corpus,lg, filterby = LexicalToken())
analyzedlexical = parsecorpus(lexcorpus, dfparser)

failed = filter(at -> isempty(at.analyses), analyzedlexical.analyses)
failedstrs = map(psg -> psg.ctoken.passage.text, failed)
failedfreqs = filter(pr -> pr[1] in failedstrs, collect(histo))

failedvals = map(pr -> pr[1], failedfreqs)
open("failed-attic-core.txt", "w") do io
    write(io, join(failedvals, "\n"))
end

analyzedlexical


# Each token as a vector of Analysis objects.
# For an Analysis you can check the type this way:
# ANALYSIS_OBJECT.form |> greekForm |> typeof
#
allanalyses = filter(analyzedlexical.analyses) do lextoken
    ! isempty(lextoken.analyses)
end
analysistypes = map(allanalyses) do tkn 
    tkn.analyses[1] |> greekForm |> typeof
end |> unique

verbforms = filter(allanalyses) do tkn
    tknform = tkn.analyses[1] |> greekForm 
    tknform isa GMFFiniteVerb ||
    tknform isa GMFInfinitive ||
    tknform isa GMFParticiple
end


using StatsBase
typehisto = map(verbforms) do v
    v.analyses[1] |> greekForm |> typeof
end |> countmap




finites = filter(verbforms) do v
    (v.analyses[1] |> greekForm) isa GMFFiniteVerb
end

moodhisto = map(finites) do v
    v.analyses[1] |> greekForm |> gmpMood |> label
end |> countmap

tensemoodhisto = map(finites) do v
    f1 = v.analyses[1] |> greekForm
    join([label(gmpTense(f1)), label(gmpMood(f1))], " ")
end |> countmap

persnumhisto = map(finites) do v
    f1 = v.analyses[1] |> greekForm
    join([label(gmpPerson(f1)), label(gmpNumber(f1))], " ")
end |> countmap

#=
  "future optative"      => 1
  "aorist optative"      => 3
  "future indicative"    => 6
  "present subjunctive"  => 3
  "present optative"     => 8
  "aorist indicative"    => 27
  "aorist imperative"    => 6
  "perfect indicative"   => 6
  "present indicative"   => 51
  "present imperative"   => 3
  "imperfect indicative" => 59
  "aorist subjunctive"   => 9
=#


#=
  "third plural"    => 16
  "second singular" => 23
  "first plural"    => 3
  "third singular"  => 56
  "first singular"  => 73
  "second plural"   => 11
=#



#=

Finite moods:

- indicative 149 + 94 = 243
- subj 12 + 3 = 15
- opt 12 + 6 = 18 
- imptv 9 + 2 = 11

Non-finite forms:


-  GMFInfinitive => 63 + 31 = 94
-  GMFParticiple => 70 + 74 = 144
=#

#=
xs = ["indicative", "participle", "infinitive", "optative", "subjunctive", "imperative"]
ys = [243, 144, 94, 18, 15, 11]

using Plots

Plots.bar(xs,ys, legend = false, title = "Verb forms in Lysias 1")
=#

failedstrs = map(failedfreqs) do pr
    join(pr, " ")
end

outfile = "lysias-fails-freqs.txt"
open(outfile, "w") do io
    write(outfile, join(failedstrs, "\n"))
end

alphaout = "lysias-fails-alpha.txt"
open(alphaout, "w") do io
    write(alphaout, join(sort(failedstrs), "\n"))
end



totallextokens = length(analyzedlexical)
successes = filter(analyzedlexical.analyses) do tkn
	! isempty(tkn.analyses)
end
successcounts = map(tkn -> tkn.ctoken.passage.text, successes) |> countmap |> OrderedDict
orderedcounts = sort(successcounts; byvalue = true, rev = true)
orderedkeys = keys(orderedcounts) |> collect


runningtally = []

for (i,k) in enumerate(orderedkeys)
    currval = orderedcounts[k]
    if i == 1
        push!(runningtally, currval) 
    else
        prevval = runningtally[end]
        @info("Prevval is $(prevval), add $(currval) to it.")
        push!(runningtally, (currval + prevval))
    end
end


totallextokens = length(analyzedlexical)
pcts = runningtally ./ totallextokens


