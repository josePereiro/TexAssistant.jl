## --------------------------------------------------------------------------
function _expand_input_parse_args(argsv::Vector=ARGS)

    # arg settings
    argset = ArgParse.ArgParseSettings()
    @ArgParse.add_arg_table! argset begin
        "--proj", "-p"
            help = "the path to the project folder"
            arg_type = String
            default = pwd()
        "--dry-run", "-d"
            help = "Only verbosity, no action"
            arg_type = Bool
            default = false
    end
    args = ArgParse.parse_args(argsv, argset)
    to_symbol_arg_dict(args)
end

## --------------------------------------------------------------------------
_default_outfile(input_file) = string(replace(input_file, ".tex" => ""), "_expanded.tex")

## --------------------------------------------------------------------------
_get_indent(input_line) = first(split(input_line, "\\input"))

## --------------------------------------------------------------------------
function expand_inputs(;
        srcfile::String="",
        outfile::String=_default_outfile(srcfile),
        dry_run::Bool=false,
        verbose=true
    )
    
    # Set up src and dest
    srcdir = abspath(dirname(srcfile))
    outdir = abspath(dirname(outfile))
    dry_run || mkpath(outdir)
    !isfile(srcfile) && error(srcfile, " dont found!!!")

    verbose && @info("Args", srcfile, outdir, dry_run, verbose)
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
    dry_run || write(outfile, join(lines, "\n"))
    verbose && @info("Output file", outfile)
    verbose && println()

    return lines
    
end