function bc
    if set -q argv[1]
        bat -p $argv | wl-copy
    end
end