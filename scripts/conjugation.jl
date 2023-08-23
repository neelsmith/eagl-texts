using Kanones
using CitableParserBuilder

repo = pwd()
kroot = joinpath(repo |> dirname, "Kanones.jl")
ds = Kanones.coredata(kroot; atticonly = true)

αρχω = LexemeUrn("lsj.n16051")

bigmd = verb_conjugation_md(αρχω, ds)

pplist = principalparts(αρχω, ds)

preface = [
    "# Conjugation of ἄρχω",
    "",
    "## Principal parts",
    "",
    join(pplist, ", "),
    "",
  
]

open("arxw.md", "w") do io
    write(io, join(preface,"\n") * bigmd)
end