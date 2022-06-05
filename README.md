# Lazily-nvim

A standalone plugin lazy loader.

## Overview

Lazily is one third[1] of a full package manager: it only does lazy loading
of the plugins. This plugin is intended for use with lightweight package
managers such as [minpac] or [paq], or even native vim packages.

This plugin requires Neovim `0.7.0`.


## Usage

```lua
local lazily = require("lazily")

-- This is optional. Use it to specify extra options.
lazily.setup{
    -- Default uses vim8 packages. This works with minpac and paq
    load = lazily.packadd;
    -- To search packages in a specified directory use
    load = lazily.pathadd(vim.fn.stdpath("data") .. "/plugins");
    -- To use it with packer (though why would you do that?)
    load = packer.use;
}

lazily.use("my-plugin", {
    autocmd = {
        event = {"BufEnter", "BufNew"};
        pattern = "*";
        filter = function(event)
            return vim.fn.isdirectory(event.match) == 1
        end;
    },
    command = "MyPlugin",
    mapping = {"n", "<leader>mp"},
    requires = {
        "my-other-plugin",
    },
})

-- To ensure the plugin is loaded, use
lazily.load("my-plugin")

-- To cancel all the lazy loading triggers, use
lazily.cancel("my-plugin")
```

See `:help lazily` for more informations.


[1]: The three thirds are downloading, loading and lazy-loading.
[paq]: https://github.com/savq/paq-nvim/
[minpac]: https://github.com/k-takata/minpac
