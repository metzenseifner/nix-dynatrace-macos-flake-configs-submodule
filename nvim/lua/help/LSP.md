-- source code for buffer commands repo:://neovim/runtime/lua/vim/lsp/buf.lua
lsp-api is the help tag.

method :: a name of a request or notification

handler :: a function that is called when a method is called (a map maps methods to handlers)

|lsp-handler|). The |vim.lsp.handlers| table defines default handlers used
when creating a new client. Keys are LSP method names:  


```
:lua print(vim.inspect(vim.tbl_keys(vim.lsp.handlers)))
```

lsp-handlers are functions with special signatures that are designed to handle
responses and notifications from LSP servers.

To configure the behavior of a builtin |lsp-handler|, the convenient method
|vim.lsp.with()| is provided for users.


 vim.lsp.handlers is a global table that contains the default mapping of
    |lsp-method| names to |lsp-handlers|.


To override the handler for the `"textDocument/definition"` method:  

    vim.lsp.handlers["textDocument/definition"] = my_custom_default_definition


Some handlers have explicitly named handler functions within the vim.lsp namespace.
(e.g. vim.lsp.diagnostic.on_publish_diagnostics).

Compare overriding them.

## Named (token) handler in vim.lsp


```lua
require('lspconfig').rust_analyzer.setup {
  handlers = { -- assign to handlers
    ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        -- Disable virtual_text
        virtual_text = false
      }
    ),
  }
```

## Unnamed handler function override

```lua
local on_references = vim.lsp.handlers["textDocument/references"] -- save reference to "references" handler by index notation
vim.lsp.handlers["textDocument/references"] = vim.lsp.with(
  on_references, {
    -- Use location list instead of quickfix list
    loclist = true,
  }
)

```
 
The |lsp-handler| will be chosen based on the current |lsp-method|
in the following order:

1. Handler passed to |vim.lsp.buf_request()|, if any.
2. Handler defined in |vim.lsp.start_client()|, if any.
3. Handler defined in |vim.lsp.handlers|, if any.

























For |lsp-request|, each |lsp-handler| has this signature:  

  function(err, result, ctx, config)
 
    Parameters:  
        {err}       (table|nil)
                        When the language server is unable to complete a
                        request, a table with information about the error is
                        sent. Otherwise, it is `nil`. See |lsp-response|.
        {result}    (Result | Params | nil)
                        When the language server is able to successfully
                        complete a request, this contains the `result` key of
                        the response. See |lsp-response|.
        {ctx}       (table)
                        Context describes additional calling state associated
                        with the handler. It consists of the following key,
                        value pairs:

                        {method}    (string)
                                    The |lsp-method| name.
                        {client_id} (number)
                                    The ID of the |vim.lsp.client|.
                        {bufnr}     (Buffer)
                                    Buffer handle, or 0 for current.
                        {params}    (table|nil)
                                    The parameters used in the original
                                    request which resulted in this handler
                                    call.
        {config}    (table)
                        Configuration for the handler.

                        Each handler can define its own configuration table
                        that allows users to customize the behavior of a
                        particular handler.

                        To configure a particular |lsp-handler|, see:
                            |lsp-handler-configuration|


    Returns:  
        The |lsp-handler| can respond by returning two values: `result, err`
        Where `err` must be shaped like an RPC error:
            `{ code, message, data? }`

        You can use |vim.lsp.rpc.rpc_response_error()| to create this object.


                                                        *diagnostic-structure*
A diagnostic is a Lua table with the following keys. Required keys are
indicated with (*):

    bufnr: Buffer number
    lnum(*): The starting line of the diagnostic
    end_lnum: The final line of the diagnostic
    col(*): The starting column of the diagnostic
    end_col: The final column of the diagnostic
    severity: The severity of the diagnostic |vim.diagnostic.severity|
    message(*): The diagnostic text
    source: The source of the diagnostic
    code: The diagnostic code
    user_data: Arbitrary data plugins or users can add

Diagnostics use the same indexing as the rest of the Nvim API (i.e. 0-based
rows and columns). |api-indexing|

