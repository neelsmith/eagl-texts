
using Kanones
#using CitableBase, CitableCorpus, CitableText
using Orthography, PolytonicGreek
using CitableParserBuilder


# Build a parser with validated vocab from LSJ and hypothesized dataset
# from an LSJMining dataset in adjacent directory.
function alllitgreek(kroot = pwd(); atticonly = false)
    # 1. demo vocab:
    lgr = joinpath(kroot, "datasets", "literarygreek-rules")
    ionic = joinpath(kroot, "datasets", "ionic")
    # 2. manually validated LSJ vocab:
    lsj = joinpath(kroot, "datasets", "lsj-vocab")
    # 3. manually validated NOT in LSJ:
    extra = joinpath(kroot, "datasets", "extra")
    # 4. hypothesized data from LSJMining
    lsjx = joinpath("..", "LSJMining.jl", "kanonesdata","lsjx")
    atticonly ?  dataset([lgr, lsj, extra, lsjx]) :  dataset([lgr, ionic, lsj, extra, lsjx]) 
end

# Build a parser with demo vocab and manually validated vocab from LSJ.
function coredata(kroot = pwd(); atticonly = false)
    # 1. rules with demo vocab:
    lgr = joinpath(kroot, "datasets", "literarygreek-rules")
    ionic = joinpath(pwd(), "datasets", "ionic")
    # 2. manually validated LSJ vocab:
    lsj = joinpath(kroot, "datasets", "lsj-vocab")
    # 3. manually validated NOT in LSJ:
    extra = joinpath(kroot, "datasets", "extra")
    atticonly ? dataset([lgr, lsj, extra]) :  dataset([lgr, ionic, lsj, extra]) 
end

kroot = joinpath(pwd() |> dirname, "Kanones.jl")
ds = coredata(kroot, atticonly = true)
sp = stringParser(ds)

eaglbase = joinpath(pwd() |> dirname, "eagl-texts")
f = joinpath(eaglbase, "texts", "lysias1-filtered.cex") 
isfile(f)
corpus = fromcex(f, CitableTextCorpus, FileReader)

lg = literaryGreek()
histo =  corpus_histo(corpus, lg, filterby = LexicalToken())
lexcorpus = tokenizedcorpus(corpus,lg, filterby = LexicalToken())
analyzedlexical = parsecorpus(lexcorpus, sp)

failed = filter(at -> isempty(at.analyses), analyzedlexical.analyses)
failedstrs = map(psg -> psg.ctoken.passage.text, failed)
failedfreqs = filter(pr -> pr[1] in failedstrs, collect(histo))

failedvals = map(pr -> pr[1], failedfreqs)


open("failed.txt", "w") do io
    write(io, join(failedvals, "\n"))
end

