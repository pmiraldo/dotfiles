# if status is-interactive
#     # Commands to run in interactive sessions can go here
#     true
# end
# ~/.local/bin/mise activate fish | source

# alias sudo
alias sudo="sudo "

# alias thefuck
# eval $(thefuck --alias fuck)

# alias batcat
alias less="batcat --theme=zenburn"

# alias apt -> nala
alias apt="nala"
# alias apt-get="nala"

# fancy ls
# alias ls="eza -G -l"
alias ls="colorls --report --gs -1"

# simplify ninja
alias n="ninja"

# popup tmux
# alias pop="tmux popup -h 75% -w 75% fish"
# function pop
#     tmux popup -h 75% -w 75% $argv[1]
# end
# alias push="tmux display-popup -C "

# better cd
# alias cd="z"



# machine-private settings / secrets (not tracked)
test -f ~/.config/fish/local.fish; and source ~/.config/fish/local.fish
