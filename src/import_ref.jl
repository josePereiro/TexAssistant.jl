## ------------------------------------------------------------------------------------------------------------------
function bib_to_str(d, key)
    emd = d[key]
    head = string("@", emd["type"], "{", key, ",")
    body = []
    for (key, dat) in emd
        key in ["type"] && continue
        push!(body, string(key, " = {", dat, "}"))
    end
    string(head, "\n\t", join(body, ",\n\t"), "\n}")
end

## ------------------------------------------------------------------------------------------------------------------
_get_glob_bib() = get(ENV, "GLOBAL_BIB_LIBRARY") do
    error("You must set a 'GLOBAL_BIB_LIBRARY' environmental variable pointing to a .bib")
end

## ------------------------------------------------------------------------------------------------------------------
function parse_emtry(argsv::Vector)
    s = ArgParse.ArgParseSettings()
    ArgParse.@add_arg_table! s begin
        "--bibkey", "-k"
            help = "the bibkey of the item"
            arg_type = String
            required = true
    end
    ArgParse.parse_args(argsv, s)["bibkey"]
end

## ------------------------------------------------------------------------------------------------------------------
function _import_ref_cli(argsv::Vector=ARGS)

    id = parse_emtry(argsv)

    # source .bib
    SRC_BIB = _get_glob_bib()
    @assert isfile(SRC_BIB) SRC_BIB
    @info("SRC", SRC_BIB)
    
    # dest .bib
    DEST_BIB = joinpath(pwd(), string(basename(pwd()), ".bib")) # default
    for file in readdir(pwd(); join = true)
        endswith(file, ".bib") || continue # local
        DEST_BIB = file
        break
    end
    !isfile(DEST_BIB) && touch(DEST_BIB)
    @info("DEST", DEST_BIB)

    # read src
    SRC = read(SRC_BIB, String)
    src_preamble, src_result = BibTeX.parse_bibtex(SRC)
    !haskey(src_result, id) && (@error("id (\"$(id)\") misssing from \"$(SRC_BIB)\""); return)

    # read dest
    DEST = read(DEST_BIB, String)
    dest_preamble, dest_result = BibTeX.parse_bibtex(DEST)
    haskey(dest_result, id) && (@warn("id (\"$(id)\") already at \"$(SRC_BIB)\" (skiping)"); return)

    # Updating 
    NEW_STR = bib_to_str(src_result, id)
    DEST *= "\n\n"
    DEST *= NEW_STR
    write(DEST_BIB, DEST)

    @info("Done!!!, emptry added!!!"); println()
    println(NEW_STR)
end