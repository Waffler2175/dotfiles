if status is-interactive
    if not set -q NVIM
	fastfetch
    end
    # Commands to run in interactive sessions can go here
    oh-my-posh init fish --config "negligible" | source
end

