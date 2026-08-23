# json

`json`/`jsonc` LSP (`jsonls`, via Mason's `json-lsp`) and formatting (`prettier`)
configuration for [BeastVim](https://github.com/loctvl842/BeastVim). Built only
for the BeastVim ecosystem — it calls `Lsp.register`, which is provided
globally by BeastVim's `beast.libs.lsp`. Not usable standalone.

## Install

```lua
{
  name = "json",
  src = gh("BeastVim/json"),
  lazy = { filetype = { "json", "jsonc" } },
  config = function() require("json").setup() end,
}
```
