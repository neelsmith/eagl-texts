### A Pluto.jl notebook ###
# v0.19.24

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 4fa2c004-746d-448b-a163-fa6c396f1003
# ╠═╡ show_logs = false
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.add([
		Pkg.PackageSpec(name="TranscodingStreams",  version="0.9.11"),
		Pkg.PackageSpec("PlutoUI"),
		Pkg.PackageSpec("GreekSyntax"),
		Pkg.PackageSpec("LatinSyntax"),
		Pkg.PackageSpec("LatinOrthography"), 
		Pkg.PackageSpec("PolytonicGreek"),
		Pkg.PackageSpec("Downloads"),
		Pkg.PackageSpec("CitableText"),
		Pkg.PackageSpec("Dates"),
		Pkg.PackageSpec("Kroki"),
		])
	using Kroki
	using GreekSyntax, LatinSyntax
	using LatinOrthography, PolytonicGreek
	using Downloads
	using CitableText
	using Dates
	using PlutoUI

	md"""*Unhide this cell to see environment configuration.*"""
end

# ╔═╡ 7e0a834e-ab93-4320-9119-cbd04495dc9b
nbversion = "0.2.1";

# ╔═╡ 5ede902b-be5d-479a-9816-209b1adb7ce8
md"""**Notebook version $(nbversion)**  *See version history* $(@bind history CheckBox())"""

# ╔═╡ 31d7e8b4-e4b3-450e-9401-f4256dfe8d53
if history
	md"""
- **0.2.2**: 	pin version of `TranscodingStreams` before API was broken.
- **0.2.1**: 	use version `0.13.8` of `GreekSyntax` package and `0.3.2` of `LatinSyntax`
- **0.2.0**: 	add selection of language and orthography for corpus
- **0.1.2**: 	use version `0.13.4` of `GreekSyntax` package
- **0.1.1**: update internal package manifest
- **0.1.0**: initial release	
	"""
end

# ╔═╡ 93b49926-9104-11ed-19c6-df715bde3818
md"""# Build a web site for syntactically annotated texts

"""

# ╔═╡ 24abee74-963f-465a-b889-b88ecddca4f3
begin
	defaultoutdir = joinpath(dirname(pwd()),"scratchpad")
	md"""*Output directory* $(@bind  outputdir confirm(TextField(80; default = defaultoutdir)))
	"""
end

# ╔═╡ 3d38cad6-d10e-4eac-b33c-1cb15ac8f198
md"""
*Label for text* $(@bind textlabel
	TextField(80; placeholder = 
	"Lysias, Oration 1"))
"""

# ╔═╡ 690f1218-fa0f-4410-9ec2-6d4846189111
begin
	orthomenu = ["litgreek" => "Greek: literary orthography", "latin23" => "Latin: 23-character alphabet","latin24" => "Latin: 24-character alphabet", "latin25" => "Latin: 25-character alphabet"]
	
md"""
*Language and orthography of your corpus*: $(@bind ortho Select(orthomenu))
"""
end

# ╔═╡ 6f8812cd-5bcb-4db7-a431-bc7402b0d187
md"""*Load annotations from* $(@bind srctype Select(["", "url", "file"]))"""

# ╔═╡ 45bb7468-adfe-41c9-9ab9-d3c597e380f8
if srctype == "url"
	md"""*Source URL*: $(@bind url TextField(80; default = 
	"https://raw.githubusercontent.com/neelsmith/eagl-texts/main/annotations/Lysias1_annotations.cex"))
	"""
elseif srctype == "file"
	
	defaultdir = joinpath(dirname(pwd()), "annotations")
	md"""*Source directory*: $(@bind basedir TextField(80; default = defaultdir))"""
end

# ╔═╡ 2fd228b9-1a78-49c9-862e-3e7e11a3b2e0
if srctype == "file"
	
	cexfiles = filter(readdir(basedir)) do fname
		endswith(fname, ".cex")
	end
	datasets = [""]
	for f in cexfiles
		push!(datasets,f)
	end
	md"""*Choose a file* $(@bind dataset Select(datasets))"""
end

# ╔═╡ ca9cc614-b1c3-4b31-a263-e80a09a978a0
md"""*All settings correct: Go!* $(@bind runit CheckBox())"""

# ╔═╡ 60c5db9e-5185-42e1-a5cd-49ec516f07f3
html"""
<br/><br/><br/>
<hr/>
"""

# ╔═╡ d8df443c-44b0-4243-ae40-9ad1a684281f
md"> Check settings and load data"

# ╔═╡ 5f0898f7-bc7d-479c-a304-c84ded1a9a90
if runit
			
	open(joinpath(outputdir, "syntax.css"), "w") do io
		write(io, GreekSyntax.defaultcss() * "\n")
	end

	open(joinpath(outputdir, "page.css"), "w") do io
		write(io, GreekSyntax.pagecss())
	end


	md"""*Wrote CSS files to $(outputdir).*"""	
else
	md"""*Waiting to write CSS files...*"""
end


# ╔═╡ 792a44c9-093d-431d-9277-a77163433570
"""Make directory for syntax diagrams."""
function mkpngdir(outdir)
	imgdir = if startswith(outdir, "/")
		joinpath(outdir, "pngs")
	else
		joinpath(pwd(), outdir, "pngs")
	end
	mkpath(imgdir)
end

# ╔═╡ 3e11aa5f-f020-4229-95c6-3f64145738ed
pngdir = mkpngdir(outputdir)

# ╔═╡ cb126faf-7678-4087-999b-349e03ab929f
"""Instantiate `OrthographicSystem` for user's menu choice.
"""
function orthography()
	if ortho == "litgreek"
		literaryGreek()
	elseif ortho == "latin23"
		latin23()
	else
		nothing
	end
end

# ╔═╡ 9447b4e0-e2e3-4c5f-9958-ede1549d0027
(sentences, groups, tokens) = if srctype == "file"
	src = joinpath(basedir, dataset) |> readlines
	readdelimited(src, orthography())
elseif srctype == "url"
	src = Downloads.download(url) |> readlines
	readdelimited(src, orthography())
else
	(nothing, nothing, nothing)
end

# ╔═╡ 49f787aa-63ec-4883-ac98-49310bdad7d8
"True if all settings are OK"
function settingsok()
	if ! isdir(outputdir) || isempty(textlabel) || isnothing(sentences)
		false
	else
		true
	end
end

# ╔═╡ d0e510b8-edab-4249-9609-fd082225def2
md"""> Functions composing HTML"""

# ╔═╡ 903326cf-c9eb-45fd-b6a9-d131bebab02a

"""Wrap page title and body content in HTML elements,
and include link to syntax.css.
"""
function wrap_page(title, content)
    """<html>
    <head>
    <title>$(title)</title>
    <link rel=\"stylesheet\" href=\"syntax.css\">
    <link rel=\"stylesheet\" href=\"page.css\">
    </head>
    <body>$(content)</body>
    </html>"""
end

# ╔═╡ 3faa116c-df96-4110-bf43-daef4b4ccdb1

"""Compose navigation links for page with index `idx`.
"""
function navlinks(idx::Int, sentencelist::Vector{SentenceAnnotation})
    nxt = ""
    prev = ""
    if idx == 1
        nxtpsg = sentences[idx + 1].range |> passagecomponent
        nxt = "<a href=\"./$(nxtpsg).html\">$(nxtpsg)</a>"
    
        prev = ""
        
    elseif idx == length(sentences)
        nxt = ""

        prevpsg = sentences[idx - 1].range |> passagecomponent
        prev = "<a href=\"./$(prevpsg).html\">$(prevpsg)</a>"

    else
        nxtpsg = sentences[idx + 1].range |> passagecomponent
        nxt = "<a href=\"./$(nxtpsg).html\">$(nxtpsg)</a>"

        prevpsg = sentences[idx - 1].range |> passagecomponent
        prev = "<a href=\"./$(prevpsg).html\">$(prevpsg)</a>"
    end
nav = "<p class=\"nav\">$(prev) | $(nxt)</p>"
end

# ╔═╡ 5fff3d5c-ff81-444f-b8f1-4c12ded8e25b

"""Compose HMTL page for sentence number `idx`.
"""
function webpage(idx, sentences, groups, tokens, versionid)
    sentence = sentences[idx]
    @info("$(idx). Writing page for $(sentence.sequence) == $(sentence.range)...")

    # Compose parts of page content:

    #  Heading and subheading
    psg = passagecomponent(sentence.range)
    pagetitle = "$(textlabel),  $(psg)"
    hdg = "<h1>$(pagetitle)</h1>"
    subhead = "<h2>Sentence $(sentence.sequence)</h2>"
     
    # navigation links
    nav = navlinks(idx, sentences)

    # Continuous text view:
    plaintext = htmltext(sentence.range, sentences, tokens, sov = false, vucolor = false, syntaxtips = true)


    # Text colored by verbal expression:
    key1 = "<div class=\"key right\"><strong>Highlighting</strong>:" *  GreekSyntax.sovkey() * "</div>"
    txtdisplay1 = "<div class=\"passage\">" * htmltext_indented(sentence, groups, tokens, sov = true, vucolor = false) * "</div>"

    # Text indented by level of subordination
    pagegroups = GreekSyntax.groupsforsentence(sentence, groups)
    key2 = "<div class=\"key left\"><strong>Color code</strong>:" * GreekSyntax.htmlgrouplist(pagegroups) * "</div>"
    txtdisplay2 = "<div class=\"passage\">" * htmltext(sentence, tokens, sov = true, vucolor = true) * "</div>"

    # Syntax diagram (pre-generated PNG)
    @info("Linking to image for $(sentence.sequence) == $(sentence.range)")
    imglink = "<img src=\"pngs/sentence_$(sentence.sequence).png\" alt=\"Syntax diagram, sentence $(sentence.sequence)\"/>"
    diagram = "<div class=\"diagram\">" * imglink * "</div>"
    
    m = now() |> monthname
    d = now() |> day
    y = now() |> year
    footer = "<footer>Site created by Pluto notebook <code>webpublisher.jl</code>, version $(versionid), on $(m) $(d), $(y).</footer>"

    # String all the parts together!
    htmlparts = [hdg, nav, subhead, plaintext, txtdisplay1, txtdisplay2, key1, key2, diagram, footer]
    bodycontent = join(htmlparts, "\n\n")
    wrap_page(pagetitle, bodycontent)
end


# ╔═╡ 2f4f4048-3998-4743-aa5c-641e82e23c22

"""Write HTML page for sentence `num` to HTML file.
"""
function publishsentence(num, sentences, groups, tokens, versionid; pngdir = pngdir, outdir = outputdir)
    idx = findfirst(s -> s.sequence == num, sentences)
    # Write png for page:
    sentence = sentences[idx]
    @info("Composing diagram for sentence $(num) == $(sentence.range)")
    pngout = mermaiddiagram(sentence, tokens, format = "png")
    write(joinpath(pngdir, "sentence_$(sentence.sequence).png"), pngout)

    psg = passagecomponent(sentence.range)
    pagehtml = webpage(idx, sentences, groups, tokens, versionid)
    open(joinpath(outputdir, "$(psg).html"), "w") do io
        write(io, pagehtml)
    end
    @info("Done: wrote HTML page for sentence $(num) in $(outputdir) as $(psg).html.")
end

# ╔═╡ 94054ecf-5089-4f36-a94d-62de91ff022a
"""Write HTML pages for all sentences in `sentences`.
"""
function publishall(sentences, groups, tokens, versionid)
    for sentence in sentences
        publishsentence(sentence.sequence, sentences, groups, tokens, versionid)   
    end
    @info("Done: wrote $(length(sentences)) HTML pages linked to accompanying PNG file in $(outputdir). (Now in $(pwd()))")
end

# ╔═╡ f6337759-7c80-43db-b050-a7895e201542
if ! runit 
else
	if settingsok()		
		publishall(sentences, groups, tokens, nbversion)
		md"""**Done**: wrote **$(length(sentences))** HTML pages linked to accompanying PNG file in *$(outputdir)*."""
	else
		md"""*Please complete settings.*"""
	end
end

# ╔═╡ Cell order:
# ╟─7e0a834e-ab93-4320-9119-cbd04495dc9b
# ╟─4fa2c004-746d-448b-a163-fa6c396f1003
# ╟─5ede902b-be5d-479a-9816-209b1adb7ce8
# ╟─31d7e8b4-e4b3-450e-9401-f4256dfe8d53
# ╟─93b49926-9104-11ed-19c6-df715bde3818
# ╟─24abee74-963f-465a-b889-b88ecddca4f3
# ╟─3d38cad6-d10e-4eac-b33c-1cb15ac8f198
# ╟─690f1218-fa0f-4410-9ec2-6d4846189111
# ╟─6f8812cd-5bcb-4db7-a431-bc7402b0d187
# ╟─45bb7468-adfe-41c9-9ab9-d3c597e380f8
# ╟─2fd228b9-1a78-49c9-862e-3e7e11a3b2e0
# ╟─ca9cc614-b1c3-4b31-a263-e80a09a978a0
# ╟─f6337759-7c80-43db-b050-a7895e201542
# ╟─60c5db9e-5185-42e1-a5cd-49ec516f07f3
# ╟─d8df443c-44b0-4243-ae40-9ad1a684281f
# ╟─9447b4e0-e2e3-4c5f-9958-ede1549d0027
# ╟─3e11aa5f-f020-4229-95c6-3f64145738ed
# ╟─5f0898f7-bc7d-479c-a304-c84ded1a9a90
# ╟─49f787aa-63ec-4883-ac98-49310bdad7d8
# ╟─792a44c9-093d-431d-9277-a77163433570
# ╟─cb126faf-7678-4087-999b-349e03ab929f
# ╟─d0e510b8-edab-4249-9609-fd082225def2
# ╟─94054ecf-5089-4f36-a94d-62de91ff022a
# ╟─2f4f4048-3998-4743-aa5c-641e82e23c22
# ╟─5fff3d5c-ff81-444f-b8f1-4c12ded8e25b
# ╟─903326cf-c9eb-45fd-b6a9-d131bebab02a
# ╟─3faa116c-df96-4110-bf43-daef4b4ccdb1
