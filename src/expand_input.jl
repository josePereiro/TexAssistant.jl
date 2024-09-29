## --------------------------------------------------------------------------
_default_outfile(input_file) = replace(input_file, ".tex" => ".expanded.tex")

## --------------------------------------------------------------------------
_get_indent(input_line) = first(split(input_line, "\\input"))

## --------------------------------------------------------------------------
function _expand_inputs_parse_args(argsv::Vector=ARGS)

    # arg settings
    argset = ArgParse.ArgParseSettings()
    @ArgParse.add_arg_table! argset begin
    "--srcfile", "-f"
        help = "the path to the main file"
        arg_type = String
        default = load_setting("maintex", pwd())
    "--outfile", "-o"
        help = "the path to the main file"
        arg_type = String
        default = ""
    "--dry-run", "-d"
        help = "Only verbosity, no action"
        action = :store_true
    "--commented", "-c"
        help = "The extended file is all commented"
        action = :store_true
    "--verbose", "-v"
        help = "Print info while executing"
        action = :store_true
    end
    args = ArgParse.parse_args(argsv, argset)
    isempty(args["outfile"]) && (args["outfile"] = _default_outfile(args["srcfile"]))
    to_symbol_arg_dict(args)
end

## --------------------------------------------------------------------------
function expand_inputs(;
        srcfile::String="",
        outfile::String=_default_outfile(srcfile),
        dry_run::Bool=false,
        verbose=true, 
        commented=true
    )
    
    # Set up src and dest
    srcdir = abspath(dirname(srcfile))
    outdir = abspath(dirname(outfile))
    dry_run || mkpath(outdir)
    !isfile(srcfile) && error(srcfile, " dont found!!!")

    verbose && @info("Args", srcfile, outfile, dry_run, verbose, commented)
    verbose && println()
    
    # expand infiles
    input_file_found = true
    lines = readlines(srcfile)
    while input_file_found
        input_file_found = false
        for li in eachindex(lines)
            line = lines[li]
            input_file = extract_input_file(line)
            isempty(input_file) && continue
            
            # if input file found, I'll inserted in place
            verbose && @info("Found input file", input_file)
            input_file_found = true

            input_file = joinpath(srcdir, input_file)
            !isfile(input_file) && error(input_file, " dont found. src line ", li, ": ", line)

            input_file_lines = readlines(input_file)
            for i in reverse(eachindex(input_file_lines))
                new_line = input_file_lines[i]
                
                isfirst = (i == firstindex(input_file_lines))
                isfirst ? lines[li] = new_line : insert!(lines, li + 1, new_line)
            end
            break
        end
    end
    verbose && println()

    # write to dest
    # dry_run || write(outfile, join(lines, "\n"))
    if !dry_run
        commented && (lines = map((line) -> string("% ", line), lines))
        open(outfile, "w") do io
            foreach((line) -> println(io, line), lines)
        end
    end
    verbose && @info("Output file", outfile)
    verbose && println()

    return lines
    
end