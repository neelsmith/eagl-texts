using Kanones
#using CitableBase, CitableCorpus, CitableText
using Orthography, PolytonicGreek
using CitableParserBuilder

using Dates
startstamp = now()

projdir = ENV["JULIA_PROJECT"]
msg = """PROJECT IS $(ENV["JULIA_PROJECT"])"""
@info(msg)

# Build a parser with validated vocab from LSJ and hypothesized dataset
# from an LSJMining dataset in adjacent directory.
function alllitgreek(parentdir = pwd(); atticonly = false)
    kroot = joinpath(parentdir, "Kanones.jl")
    lsjroot = joinpath(parentdir, "LSJMining.jl")

    # 1. demo vocab:
    lgr = joinpath(kroot, "datasets", "literarygreek-rules")
    ionic = joinpath(kroot, "datasets", "ionic")
    # 2. manually validated LSJ vocab:
    lsj = joinpath(kroot, "datasets", "lsj-vocab")
    # 3. manually validated NOT in LSJ:
    extra = joinpath(kroot, "datasets", "extra")
    # 4. hypothesized data from LSJMining
    lsjx = joinpath(lsjroot, "LSJMining.jl", "kanonesdata","lsjx")
    atticonly ?  dataset([lgr, lsj, extra, lsjx]) :  dataset([lgr, ionic, lsj, extra, lsjx]) 
end

kroot = joinpath(projdir |> dirname |> dirname, "Kanones.jl")

bigds = alllitgreek(kroot; atticonly = true)
@time mongoparser = stringParser(bigds)


# Then save the output locally to my dropbox where it's backed up



fname = "attic-" * Dates.format(startstamp, "yyyy-mm-dd-THHMM") * ".csv"
dboxroot = joinpath("/Users", "nsmith", "Dropbox", "_parsers")
outfile = joinpath(dboxroot, fname)

isdir(dboxroot)
tofile(mongoparser, outfile; delimiter = "," )
endstamp = now()
starttime = Dates.format(startstamp, "HH:MMp")
endtime = Dates.format(endstamp, "HH:MMp")
@info("Started at $starttime, ended at $endtime")
@info("Elapsed time: $(endstamp - startstamp)")


#= 8903.348201
secc = 8903
minn = secc / 60
hrr = minn / 60
=#