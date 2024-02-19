using GreekBetaCode
using Kanones
kroot = joinpath(dirname(pwd()), "Kanones.jl")
parsersrc = joinpath(kroot, "parsers", "current-core-attic.csv")
dfparser = dfParser(parsersrc)




f = joinpath(pwd(), "scripts", "lysias_on_the_murder_of_eratosthenes.csv")

lemmata = map(readlines(f)) do ln
    cols = split(ln, ",")
    raw = cols[1]
    lemma = split(raw)[1]
    normed = lowercase(lemma) |> B |> U 
    fix1 = replace(normed, "έω" => "ῶ")
    fix2 = replace(fix1, "ςσ" => "σσ")
    fix3 = replace(fix2, r"/.+" => "")
    fix4 = replace(fix3, "έομαι" => "οῦμαι")
    fix5 = replace(fix4, r"\.\.\..+" => "")
    replace(fix5, "άω" => "ῶ")

end


parses = map(lemmata) do lemma
    (lemma = lemma, parses = parsetoken(lemma, dfparser))
end

fails = filter(parses) do tkn
    isempty(tkn.parses)
end

failedlemms = map(pr -> pr.lemma, fails)

open("failed-lemmata.txt", "w") do io
    write(io, join(failedlemms, "\n"))
end