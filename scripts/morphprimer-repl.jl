using Downloads
using CitableParserBuilder
using Orthography 
using PolytonicGreek
using CitableBase, CitableText, CitableCorpus
using Kanones

using StatsBase
using OrderedCollections
using DataFrames

using Plots
plotly()

# Maybe this belongs in Kanones
function hacklabel(lexurn)
	s = string(lexurn)
	if startswith(s, "lsjx.")
		stripped = replace(s, "lsjx." => "")
		haskey(labeldictx, stripped) ? string(s, "@", labeldictx[stripped]) : string(s, "@labelmissing")
	elseif startswith(s, "lsj.")
		stripped = replace(s, "lsj." => "")
		haskey(labeldict, stripped) ? string(s, "@", labeldict[stripped]) : 
		string(s, "@labelmissing")
	else
		string(lexurn, "@nolabel")
	end
end


# 1. Corpus
src = joinpath(pwd() |> dirname,  "texts", "oeconomicus.cex")
corpus = fromcex(src, CitableTextCorpus, FileReader)

# 2. Citable tokens
lg = literaryGreek()
citabletokens = tokenize(corpus, lg)

# 3. Analyzed tokens
parsersrc = "/Users/nsmith/Dropbox/_kanones/literarygreek-all-2023-05-25.csv"
parser = dfParser(read(parsersrc))
analyzedtokens = parsecorpus(tokenizedcorpus(corpus,lg, filterby = LexicalToken()), parser)


# 4. Indexing tokens and lexemes
tokenindex = corpusindex(corpus, lg)
lexdict  = lexemedictionary(analyzedtokens.analyses, tokenindex)


# 5. Surveying morphology of a corpus
histo = corpus_histo(corpus, lg, filterby = LexicalToken())#, normalizer =  knormal)


"""Histogram of lexemes properly belongs in `CitableParserBuilder`."""
function lexemehisto(alist)
	flattened = map(at -> at.analyses, alist) |> Iterators.flatten |> collect
	lexflattened = map(at -> hacklabel(at.lexeme), flattened)
	sort!(OrderedDict(countmap(lexflattened)); byvalue=true, rev=true)
end
lexhisto = lexemehisto(analyzedtokens.analyses)


# Find unanalyzed:
failed = filter(at -> isempty(at.analyses), analyzedtokens.analyses)
"""Histogram of forms properly belongs in `CitableParserBuilder`."""
function formshisto(alist)
	flattened = map(at -> at.ctoken.passage.text, alist) |> collect
	
	sort!(OrderedDict(countmap(flattened)); byvalue=true, rev=true)
end

failedhisto = formshisto(failed)

# 6. Label lexemes
labeldict = Kanones.lsjdict()
labeldictx = Kanones.lsjxdict()


# 7. Surveying morphology of Greek forms

