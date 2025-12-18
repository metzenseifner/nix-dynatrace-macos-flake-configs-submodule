return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = "markdown",
  build = function()
    if vim.fn.executable("npm") == 0 then
      vim.notify("npm not found. markdown-preview.nvim requires npm to build.", vim.log.levels.WARN)
      return
    end
    local install_path = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim/app"
    local install_script = install_path .. "/install.sh"
    
    if vim.fn.executable("bash") == 1 and vim.fn.filereadable(install_script) == 1 then
      vim.fn.system({"bash", install_script})
    end
    
    local result = vim.fn.system({"npm", "install", "--prefix", install_path})
    if vim.v.shell_error ~= 0 then
      vim.notify("Failed to install markdown-preview.nvim dependencies: " .. result, vim.log.levels.WARN)
    end
  end,
  init = function()
    vim.g.mkdp_theme = "light"
    vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/lua/plugins/markdown-preview/latex.css")
    vim.g.mkdp_browser = "firefox"
    vim.g.mkdp_open_to_the_world = 0
    vim.g.mkdp_open_ip = "127.0.0.1"
    vim.g.mkdp_port = "8080"
    vim.g.mkdp_echo_preview_url = 1
  end,
  keys = {
    {
      "<leader><leader>o",
      "<cmd>MarkdownPreview<cr>",
      desc = "Markdown Preview",
      ft = "markdown",
    },
  },
}
