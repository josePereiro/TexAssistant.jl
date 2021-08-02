const SETTINGS_FILE_NAME = "TexAssistant.toml"

is_setting_file(file) = endswith(basename(file), SETTINGS_FILE_NAME)

function load_settings(path=pwd())
    if isdir(path) && !(ishomedir(path) || isrootdir(path))
        @info("isdir(path)", path)
        setfile = joinpath(path, SETTINGS_FILE_NAME)
        return isfile(setfile) ? 
            TOML.parsefile(setfile) : 
            load_settings(dirname(path))
    elseif isfile(path) && is_setting_file(path)
        @info("isfile(path) && is_setting_file(path)", path)
        return TOML.parsefile(path)
    end
    return Dict{String, Any}()
end