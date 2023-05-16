using CitableText

function readem()
    f = joinpath(pwd(), "texts", "oeconomicus-indexed.cex")
    lns = readlines(f)[2:end]
    columnized = map(ln -> split(ln, "|"), lns)
    filter(row -> length(row) == 3, columnized)
end



function formatspeakers(cols)
    u = CtsUrn(cols[1])
    s = "\n\n*" * cols[3] * "*: " * cols[2]
    s
end


function writem(delimited)
    basedir = "/Users/neelsmith/Desktop/xenrevised/xenchaps"
    currchap = ""
    pg = ""
    for cols in filter(row -> length(row) == 3, delimited)
        psg = collapsePassageBy(CtsUrn(cols[1]),1) |> passagecomponent
        if psg == currchap
            pg = pg * "\n\n" * formatspeakers(cols)
        else
            if ! isempty(currchap)
                outfile = joinpath(basedir, currchap * ".md")
                @info("Write $(outfile)")
                open(outfile,"w") do io
                    write(outfile, pg)
                end
            end
            println(currchap)
            # println(pg)
            currchap = psg
            pg = formatspeakers(cols)
        end
    end
end


txt = readem()
txt |> writem

join(txt[end],"-")