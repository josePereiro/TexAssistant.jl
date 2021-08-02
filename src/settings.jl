const SETTINGS_FILE_NAME = "TexAssistant.toml"

is_setting_file(file) = isfile(file) && endswith(basename(file), SETTINGS_FILE_NAME)

function current_proj(path=pwd())
    !isdir(path) && return path
    if !(ishomedir(path) || isrootdir(path))
        setfile = joinpath(path, SETTINGS_FILE_NAME)
        isfile(setfile) && return setfile
        return current_proj(dirname(path))
    end
    return path
end

function load_settings(;path = pwd())
    setfile = current_proj(path)
    is_setting_file(setfile) ? TOML.parsefile(setfile) : Dict{String, Any}()
end

function load_setting(k, dflt; path = pwd())
    sets = load_settings(;path)
    get(sets, k, dflt)
end

load_setting(k; path=pwd()) = load_setting(k, ""; path)

