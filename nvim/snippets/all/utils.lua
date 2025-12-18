-- FunctionNode https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#functionnode
-- f(args, parent, user_args) whereby parent is the parent snippet or node, user_args from opts.user_args
return {
  -- Usage:
  --   timestamp
  s('timestamp', f(function(args, snip, user_arg_1)
    -- Try to use the date_utils module if available
    local ok, date_utils = pcall(require, 'date_utils')
    if ok and date_utils.timestamp then
      return date_utils.timestamp()
    end
    
    -- Fallback to os.date if external tools fail
    return os.date("%Y-%m-%d %H:%M:%S")
  end, {})),


}
