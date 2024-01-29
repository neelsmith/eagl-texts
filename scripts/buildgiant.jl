using Kanones
using CitableBase, CitableCorpus, CitableText
using Orthography, PolytonicGreek
using CitableParserBuilder

using Dates

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

kroot = joinpath(pwd() |> dirname, "Kanones.jl")

bigds = alllitgreek(kroot; atticonly = true)
@time mongoparser = stringParser(bigds)


# Then save the output locally to my dropbox where it's backed up


timestamp = now()
fname = Dates.format(timestamp, "yyyy-mm-dd-THHMM") * ".csv"
dboxroot = joinpath("Users", "nsmith", "Dropbox")
outfile = joinpath(dboxroot, fname)

tofile(mongoparser, outfile; delimiter = "," )