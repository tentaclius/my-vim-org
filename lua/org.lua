function maybe(...)
   local arg = {...}
   local a = nil
   for i,v in ipairs(arg) do
      if type(v) == "function" then
         a, err = v(a)
         if a == nil then return nil, err end
      else
         a = v
      end
   end
   return a
end

function getline(lnum)
   return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
end

-----------------------------------------------------------------------------------------------------------------------
-- OrgMode
-----------------------------------------------------------------------------------------------------------------------

-- My Foldtext for Org
function myOrgFoldtext(lnum)
   local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]

   if line:match("^*+ ") then
      local n = line:match("^(*+) "):len()
      local h = ''
      for i = 1, n - 1 do h = h .. ' ' end
      return h .. '* ' .. line:sub(n + 2, 80) .. "..."
   end

   return getline(lnum):sub(1, 80) .. "..."
end

-- OrgMode find Agenda for the following week in the current buffer
function myOrgAgenda(datestr)
   local bufnr = vim.api.nvim_call_function('bufnr', {'%'})

   local lastHeaderLn = nil
   local lastHeaderTxt = nil
   local foundHeaders = {}

   local handle = io.popen("date -d '" .. datestr:gsub("'", "\\'") .. "' +'%Y-%m-%d %H:%m'")
   local duedate = handle:read("*a")
   handle:close()

   -- clean the quickfix list
   vim.api.nvim_call_function('setloclist', {0, {{}}, 'r'})

   for i = 1, vim.api.nvim_buf_line_count(0) do
      local line = getline(i)
      if line:match("^[*]+ ") then
         lastHeaderLn = i
         lastHeaderTxt = line
      end

      local y, m, d, t = line:match("<(%d+)-(%d+)-(%d+)[ A-Za-z]* [0-9:]+-([0-9:]+)[ 0-9A-Za-z+]*>")
      if not y then y, m, d, t = line:match("<(%d+)-(%d+)-(%d+)[ A-Za-z]* ([0-9:]+)[ 0-9A-Za-z+]*>") end
      if not y then y, m, d = line:match("<(%d+)-(%d+)-(%d+)[ 0-9A-Za-z+]*>") end

      if y then
         local sched = ("%04d-%02d-%02d %s"):format(y, m, d, t or "")
         if sched < duedate and lastHeaderLn then
            local txt = lastHeaderTxt:match("^[* ]*(.*)"):sub(1, 100) .. '... <' .. sched .. '>'

            table.insert(foundHeaders, lastHeaderLn)
            vim.api.nvim_call_function('setloclist', {0, {{['bufnr']=bufnr, lnum=lastHeaderLn, text=txt}}, 'a'})
         end
      end
   end

   vim.api.nvim_command('lopen')

   return foundHeaders
end

-- Org Mode create next header of the same level
function myOrgMkNextHeader()
   local lnum = vim.api.nvim_win_get_cursor(0)[1]

   local hdrLevel = (function()
      for i = lnum, 1, -1 do
         local line = getline(i)
         if line:match("^[*]+ ") then
            return line:match("^([*]+) "):len()
         end
      end
      return nil
   end)()

   local nextHdr, nextHdrLn = (function()
      for i = lnum + 1, vim.api.nvim_buf_line_count(0) do
         local line = getline(i)
         if line:match("^[*]+ ") and line:match("^([*]+) "):len() <= hdrLevel then
            return line, i - 1
         end
      end
      return getline(vim.api.nvim_buf_line_count(0)), vim.api.nvim_buf_line_count(0)
   end)()

   if not nextHdr:match("^[ \t]*$") and not getline(nextHdrLn):match("^[*]+ ") then
      vim.api.nvim_call_function("append", {nextHdrLn, ""})
      nextHdrLn = nextHdrLn + 1
   end

   vim.api.nvim_call_function("append", {nextHdrLn, header(hdrLevel, "*") .. " "})
   vim.api.nvim_win_set_cursor(0, {nextHdrLn + 1, 1})
   vim.api.nvim_feedkeys("A", "m", false)
end

-- Folding for org
function myOrgFold(lnum)
   local line = getline(lnum)

   -- ignore empty lines
   if line:match("^[ \t]*$") then
      return "="
   end

   -- if this is a header, then start the level here
   if line:match("^[*]+ ") then
      local lvl = line:match("^([*]+) "):len()
      return ">" .. tostring(lvl)
   end

   -- an unknown/unrelated level
   return "="
end

