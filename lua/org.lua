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

function tableFind(table, value)
   for i, v in pairs(table) do
      if v == value then
         return i
      end
   end
   return nil
end

function getline(lnum)
   return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1]
end

function setline(lnum, text)
   return vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, {text})
end

function mkheader(n, c)
   h = ""
   for i = 1, n do h = h .. c end
   return h
end

function getIndent(line)
   local ts = vim.api.nvim_buf_get_option(0, "ts")
   local len = 0
   local i = 1

   while i <= line:len() and line:sub(i, i):match("[ \t]") do
      if line:sub(i,i) == " " then
         len = len + 1
      else
         len = len + ts
      end

      i = i + 1
   end

   return len
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

function orgParseDate(line)
   local y, m, d, t, i = line:match("<(%d+)-(%d+)-(%d+) [ A-Za-z]*([0-9:]+) ([0-9dwmy+]+)")
   if not y then y, m, d, i = line:match("<(%d+)-(%d+)-(%d+) [ A-Za-z]*([0-9dwmy+]+)") end
   if not y then y, m, d, t = line:match("<(%d+)-(%d+)-(%d+)[ A-Za-z]* [0-9:]+-([0-9:]+)[ 0-9A-Za-z+]*>") end
   if not y then y, m, d, t = line:match("<(%d+)-(%d+)-(%d+)[ A-Za-z]* ([0-9:]+)[ 0-9A-Za-z+]*>") end
   if not y then y, m, d = line:match("<(%d+)-(%d+)-(%d+)[ 0-9A-Za-z+]*>") end

   return y, m, d, t, i
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

      local y, m, d, t, i = orgParseDate(line)

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

function myOrgHeaderLevel(lnum) --> header_level, header_line_number, header_line
   for i = lnum, 1, -1 do
      local line = getline(i)
      if line:match("^[*]+ ") then
         return line:match("^([*]+) "):len(), i, line
      end
   end
   return nil
end

function myOrgFindNextHeader(lnum, hdrLevel) --> header_line, header_line_number
   for i = lnum + 1, vim.api.nvim_buf_line_count(0) do
      local line = getline(i)
      if line:match("^[*]+ ") and line:match("^([*]+) "):len() <= hdrLevel then
         return line, i - 1
      end
   end
   return getline(vim.api.nvim_buf_line_count(0)), vim.api.nvim_buf_line_count(0)
end

-- Org Mode create next header of the same level
function myOrgMkNextHeader()
   local lnum = vim.api.nvim_win_get_cursor(0)[1]
   local hdrLevel = myOrgHeaderLevel(lnum)
   local nextHdr, nextHdrLn = myOrgFindNextHeader(lnum, hdrLevel)

   --if not nextHdr:match("^[ \t]*$") and not getline(nextHdrLn):match("^[*]+ ") then
   --   vim.api.nvim_call_function("append", {nextHdrLn, ""})
   --   nextHdrLn = nextHdrLn + 1
   --end

   vim.api.nvim_call_function("append", {nextHdrLn, mkheader(hdrLevel, "*") .. " "})
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

-- Promote/demote a single line
function myOrgPromoteLine(lnum, n)
   local sw = vim.api.nvim_buf_get_option(0, "shiftwidth")
   local line = getline(lnum)

   if line:match("^[*]+ ") then
      return setline(lnum, n > 0 and ("*" .. line) or line:sub(2))
   else
      if n > 0 then
         setline(lnum, mkheader(sw, " ") .. line)
      else
         setline(lnum, n > 0 and (mkheader(sw, " ") .. line) or line:sub(math.min(getIndent(line), sw) + 1))
      end
   end
end

-- Promote/demote branch
function myOrgPromoteBranch(n)
   local lnum = vim.api.nvim_win_get_cursor(0)[1]
   local hdrLevel, startLn = myOrgHeaderLevel(lnum)
   local ts = vim.api.nvim_buf_get_option(0, "ts")
   local nextHdr, endLn = myOrgFindNextHeader(lnum, hdrLevel)
   if not hdrLevel or not startLn or not endLn then return nil end

   for i = startLn, endLn do
      local line = getline(i)
      if line:match("^[*]+ ") then
         setline(i, n > 0 and ("*" .. line) or line:sub(2))
      end
   end
end

-- Re-indent a line
function myOrgIndentLine(lnum)
   local line = getline(lnum)

   local hdrLevel, hdrLnum, hdrLine = myOrgHeaderLevel(lnum)

   if hdrLevel and not line:match("^[*]+ ") then
      setline(lnum, mkheader(hdrLevel + 1, " ") .. line:match("^[ \t]*(.*)$"))
   end
end

-- Toggle ToDo item
function myOrgToggleTodo()
   local states = {"TODO", "DONE"}
   local lnum = vim.api.nvim_win_get_cursor(0)[1]
   local line = getline(lnum)
   local si = nil

   if line:match("^[*]+ %w+") then
      local state = line:match("^[*]+ (%w+)")
      si = tableFind(states, state)
      if not si then si = 0 end
      si = si + 1
      if si > #states then si = nil end
   else
      si = 1
   end

   local headerStar = line:match("^([*]+)")
   local headerTxt = (si == 1) and line:match("^[*]+(.*)$") or line:match("^[*]+ %w+(.*)$")

   setline(lnum, headerStar .. (not si and "" or " " .. states[si]) .. headerTxt)
end

-- Go to the parent header
function myOrgGoToParent()
   local lnum = vim.api.nvim_win_get_cursor(0)[1]
   local hdrLevel, hdrLnum, hdrLine = myOrgHeaderLevel(lnum)

   if hdrLnum ~= lnum then
      vim.api.nvim_win_set_cursor(0, {hdrLnum, 1})
      return
   end
   
   for i = hdrLnum - 1, 1, -1 do
      local line = getline(i)
      if line:match("^[*]+ ") and line:match("^([*]+) "):len() < hdrLevel then
         vim.api.nvim_win_set_cursor(0, {i, 1})
         return
      end
   end
end

-- Postpone periodic todo
function myOrgPostponeTodo()
   local lnum = vim.api.nvim_win_get_cursor(0)[1]
   local hdrLevel, hdrLnum, hdrLine = myOrgHeaderLevel(lnum)
   local nxtHdr, nxtHdrLn = myOrgFindNextHeader(lnum, hdrLevel)
   local y, m, d, t, inc
   local dtLn

   maybe(
      function()
         -- find the line with the date
         for i = hdrLnum, nxtHdrLn do
            y, m, d, t, inc = orgParseDate(getline(i))
            dtLn = i
            if inc then return inc end
         end
      end,
      function(i)
         -- parse the increment
         local n, u = i:match("[+](%d+)([dwmy])")
         if n then return {num = tonumber(n), unit = u} end
      end,
      function(incr)
         -- translate the inrement suffix to the unit the `date` understands
         incr.unit = ({y="year", m="month", w="week", d="day"})[incr.unit]
         return incr
      end,
      function(incr)
         -- generate a new date using `date` cmd
         local dt = string.format("%s-%s-%s %s", y, m, d, (t and t or ""))
         local cmd = "date +'%Y-%m-%d " .. (t and "%H:%M:%S" or "") .. "' -d '" .. dt .. ' ' ..
            tostring(incr.num) .. ' ' .. incr.unit .. "'"
         local handle = io.popen(cmd)
         return handle:read("*a")
      end,
      function(dt)
         -- replace the old date with the new one
         return getline(dtLn):gsub("<[ A-Za-z0-9:+-]+>", "<" .. dt .. ' ' .. inc .. ">"):gsub("\n", "")
      end,
      function(ln) setline(dtLn, ln) end
   )
end
