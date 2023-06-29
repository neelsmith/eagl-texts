using Kanones
using CitableParserBuilder
using Downloads

parsersrc = "https://raw.githubusercontent.com/neelsmith/Kanones.jl/dev/parsers/current-core.csv"

parser = dfParser(Downloads.download(parsersrc))


txtfile = joinpath(pwd(), "texts", "apollodorus.cex")
using CitableBase, CitableText, CitableCorpus
c = fromcex(txtfile, CitableTextCorpus, FileReader)
c.passages[1]
using Orthography, PolytonicGreek
ortho = literaryGreek()

lextokens = tokenizedcorpus(c,ortho, filterby = LexicalToken())
tkns = parsecorpus(lextokens, parser)
tkns.analyses[3]

parsetoken(lextokens.passages[3].text, parser)
parsetoken("κακός", parser)

parser.df |> names |> println