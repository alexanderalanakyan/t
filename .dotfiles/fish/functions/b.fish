function b
    if set -q argv[1]
        bat $argv; and cat $argv | wl-copy
    end
end