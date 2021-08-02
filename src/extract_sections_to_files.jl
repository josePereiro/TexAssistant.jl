function extract_sections_to_files(;
        srcfile::String="",
        overwrite=false,
        dry_run::Bool=false,
        verbose = true, 
        make_bk = true, 
        names_len = 30,
    )

    # Set up src and dest
    srcdir = abspath(dirname(srcfile))
    !isfile(srcfile) && error(srcfile, " dont found!!!")

    verbose && @info("Args", srcfile, overwrite, dry_run, verbose)
    verbose && println()

    # src lines
    srclines = expand_inputs(; srcfile, verbose = false, dry_run = true)

    # make backup
    if (make_bk && !dry_run)
        bk_lines = map((line) -> string("% ", line), srclines)

        bk_file = joinpath(srcdir, replace(srcfile, ".tex" => ".bk.tex"))
        open(bk_file, "w") do io
            foreach((line) -> println(io, line), bk_lines)
        end
        verbose && @info("Backup created", bk_file)
    end

    # file tree
    file_tree = Dict{String, Dict}()
    function _register_file!(file, parent)
        haskey(file_tree, file) && error("File name collision: ", file)
        file_tree[file] = Dict(:parent => parent, :lines => String[])
    end
    
    # main file
    main_file = basename(srcfile)
    _register_file!(main_file, main_file)

    # new files
    sec_counter = 0
    subsec_counter = 0
    subsubsec_counter = 0
    function _newfilename(label) 
        fileid = string(sec_counter, ".", subsec_counter, ".", subsubsec_counter, "_")
        label = replace(label, " " => "_")
        new_name = string(fileid, label)
        if length(new_name) > names_len
            new_name = string(new_name[begin:end - names_len - 2], "..")
        end
        return string(new_name[begin:min(names_len, end)], ".tex")
    end

    # deep record
    MAIN_DEEP = 0
    SECTION_DEEP = 1
    SUBSECTION_DEEP = 2
    SUBSUBSECTION_DEEP = 3
    curr_deep = Dict()
    function _get_parent(deep)
        @assert deep >= 0
        deep -= 1
        while deep >= 0
            haskey(curr_deep, deep) && return curr_deep[deep]
            deep -= 1
        end
        return main_file
    end
    
    # initi current
    curr_file = main_file
    curr_deep[MAIN_DEEP] = main_file

    # indent
    curr_indent = ""

    for (li, line) in enumerate(srclines)

        

        # check begin new file
        texsec = extract_tex_section_label(line)
        asssec = extract_texass_sec_name(line)
        texsubsec = extract_tex_subsection_label(line)
        texsubsubsec = extract_tex_subsubsection_label(line)
        isnew_file = !isempty(string(texsec, asssec, texsubsec, texsubsubsec))

        if !isempty(texsec) || !isempty(asssec)
            # update counter
            sec_counter += 1
            subsec_counter = 0
            subsubsec_counter = 0
            
            new_file = _newfilename(string(texsec, asssec))
            new_deep = SECTION_DEEP
            
        elseif !isempty(texsubsec)
            # Do subsection stuff
            subsec_counter += 1
            subsubsec_counter = 0
            
            new_file = _newfilename(texsubsec)
            new_deep = SUBSECTION_DEEP

        elseif !isempty(texsubsubsec)
            # Do subsubsection stuff
            subsubsec_counter += 1
            
            new_file = _newfilename(texsubsubsec)
            new_deep = SUBSUBSECTION_DEEP

        end
        if isnew_file
            
            # set new current
            parent = _get_parent(new_deep)
            _register_file!(new_file, parent)
            curr_deep[new_deep] = new_file
            verbose && @info("New file", curr_file, parent, li, line)
            curr_file = new_file

            # add input to parent
            curr_indent = extract_indent(line)
            file_dat = file_tree[parent]
            push!(file_dat[:lines],
                string(curr_indent, "\\input{", new_file, "}")
            )

        end

        # main file breakers
        is_begin_document = (extract_tex_begin_label(line) == "document")
        is_begin_document && verbose && @info("Begin document", li, line)
        is_end_document = (extract_tex_end_label(line) == "document")
        is_end_document && verbose && @info("End document", li, line)
        is_end_texass_section = (extract_texass_end_label(line) == "section")
        is_end_texass_section && verbose && @info("TexAss end section", li, line)
        if is_begin_document || is_end_document
            curr_file = main_file
        elseif is_end_texass_section
            # This end goes to the new file
            file_dat = file_tree[curr_file]
            push!(file_dat[:lines], line)
            curr_file = main_file
            continue
        end

        # add line to current file
        file_dat = file_tree[curr_file]
        push!(file_dat[:lines], line)
    end

    @show curr_deep

    ## create files
    function _concat_lines(lines)
        str = join(lines, "\n")
        # small formatting
        str = replace(str, "\n\n\n" => "\n")
        return str
    end
    
    for (file, content) in file_tree
        path = joinpath(srcdir, file)
        lines = content[:lines]
        if isfile(path) && !overwrite
            verbose && @warn("File already exist", path, overwrite)
        else
            !dry_run && write(path, _concat_lines(lines))
        end
    end

    return file_tree

end