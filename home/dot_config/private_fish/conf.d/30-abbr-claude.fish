status is-interactive; or exit

# c + model (h|s|o|f) + effort (l=low, m=medium, h=high, x=xhigh, a=max).
# The bare two-letter form passes no --effort and takes the model's default.

abbr --add ch "claude --model haiku"
abbr --add chl "claude --model haiku --effort low"
abbr --add chm "claude --model haiku --effort medium"
abbr --add chh "claude --model haiku --effort high"
abbr --add chx "claude --model haiku --effort xhigh"
abbr --add cha "claude --model haiku --effort max"

abbr --add cs "claude --model sonnet"
abbr --add csl "claude --model sonnet --effort low"
abbr --add csm "claude --model sonnet --effort medium"
abbr --add csh "claude --model sonnet --effort high"
abbr --add csx "claude --model sonnet --effort xhigh"
abbr --add csa "claude --model sonnet --effort max"

abbr --add co "claude --model 'opus[1m]'"
abbr --add col "claude --model 'opus[1m]' --effort low"
abbr --add com "claude --model 'opus[1m]' --effort medium"
abbr --add coh "claude --model 'opus[1m]' --effort high"
abbr --add cox "claude --model 'opus[1m]' --effort xhigh"
abbr --add coa "claude --model 'opus[1m]' --effort max"

abbr --add cf "claude --model fable"
abbr --add cfl "claude --model fable --effort low"
abbr --add cfm "claude --model fable --effort medium"
abbr --add cfh "claude --model fable --effort high"
abbr --add cfx "claude --model fable --effort xhigh"
abbr --add cfa "claude --model fable --effort max"
