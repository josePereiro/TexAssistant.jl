function to_symbol_arg_dict(str_dict)
    sym_dict = Dict{Symbol, Any}()
    for (str_k, dat) in str_dict
        str_k = replace(str_k, "-" => "_")
        sym_dict[Symbol(str_k)] = dat
    end
    return sym_dict
end

ishomedir(path) = isdir(path) && (abspath(path) == abspath(homedir()))
isrootdir(path) = isdir(path) && (abspath(path) == abspath(dirname(path)))