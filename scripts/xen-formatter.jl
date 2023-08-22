using CitableText

function readem()
    f = joinpath(pwd(), "texts", "oeconomicus-indexed.cex")
    lns = readlines(f)[2:end]
    columnized = map(ln -> split(ln, "|"), lns)
    filter(row -> length(row) == 3, columnized)
end

function formatspeakers(cols)
    u = CtsUrn(cols[1])
    spkr = cols[3]
    body = ": " * cols[2]
    s =  startswith(spkr, ">") ?  replace(spkr, r"([>]+)(.*)" => s"\1  *\2*") * body :  "*" * spkr  * "*" * body
    "\n\n" * s
end

function writem(delimited)
    basedir = "/Users/neelsmith/Desktop/xenrevised/xenchaps"
    currchap = ""
    pg = ""
    for cols in filter(row -> length(row) == 3, delimited)
        psg = collapsePassageBy(CtsUrn(cols[1]),1) |> passagecomponent
        @info("Psg " * psg)
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
            @info("Chapter " * currchap)
            # println(pg)
            currchap = psg
            pg = formatspeakers(cols)
        end
    end
    outfile = joinpath(basedir, currchap * ".md")
    @info("Write $(outfile)")
    open(outfile,"w") do io
        write(outfile, pg)
    end
end


txt = readem()
readem() |> writem

join(txt[end],"-")

