-- The following demonstrates that the GLib glob is not necessary
-- It implements the following:
--
--  glob_to_regex(glob): convert glob-style pattern to glib regex string
--
--    Supports * and ?, but unlike GLib, does not match directory separators
--    Unlike GLib, also supports simple [] (character classes not supported).
--    [] does not match directory separators, either, even if they are
--    explicitly listed in the [].
--    Unlike GLib, special characters may be escaped with backslashes.  Of
--    course this means that if you use backslash directory separators, you
--    need to escape those as well.
--    Unlike GLib, curly braces are supported as well.  Since this is a
--    pattern, there is no way to "generate" file names this way, as the
--    shell would normally do (but see shell_expand_braces below).
--
-- The follwoing functions are not supplied by glib, but are generally
-- more useful than just providing a way to match patterns.  To just
-- match patterns, as GLib does, use the result above with glib.regex_new.
--
--  shell_expand_braces(pat): convert unescaped {} and , like the shell
--
--    Returns a table with all expansions of pat after expanding unescaped
--    {x1,[x2,...]} to x1, x2, ....  Note that mismatched braces and braces
--    without commas inside are not touched at all.  Passing any table entry
--    to glob_to_regex will leave the curly braces alone as well.
--
--  dir_regex([dir,] reg): scan a single directory for regex matches
--
--    Returns an iterator which provides entry names (without dir prepended).
--    reg may be a pattern string or a compiled pattern.  As per description,
--    only dir is scanned (or the current directory if dir is not supplied).
--    It would be trivial to convert relative_glob to use a regex as well,
--    but that is left as an exercise for the reader.
--
--  dir_glob([dir,] pat): scan a single directory for glob matches
--
--    Returns an iterator which provides entry names (without dir prepended).
--    This just calls dir_regex after converting pat with glob_to_regex.
--
--  relative_glob([dir,] pat): scan for glob pattern matches in directories
--
--   Returns an iterator which provides entry names (without dir prepended).
--   Unlike the above two, it can give entries with path separators.
--   Starting at dir (current directory if unspecified), match directory
--   entries, possibly moving into subdirectories.  Note that . and .. are
--   not supported, and absolute paths will generally fail.
--
--  glob(pat): scan for glob pattern matches in directories
--
--   Returns an iterator which provides entry names.
--   pat may contain absolute paths, as long as the absolute prefix does not
--   contain pattern elements other than curly braces/commas.  Since this
--   is a wrapper for relative_glob, . and .. after the first pattern are
--   not supported, although they are supported before it.  For example,
--   ../*.c works, but x/*/.. does not.
--
--  These routines could use some work to make them more robust (e.g.
--  supporting . and .. if they are literally in the search string), but
--  they should work for most purposes, and are certainly more than what
--  GLib provides.

if not glib then glib = require 'glib' end

function glob_to_regex(g)
   local escall = glib.regex_escape_string(g)
   local s, e, pos, re, brnest, brloc, skip, com, incc
   local dirsep = glib.regex_escape_string(glib.dir_separator)
   pos = 1
   re = ''
   brnest = 0
   com = {}
   brloc = {}
   for s, e, what in glib.regex_new('\\\\(.)'):gfind(escall) do
      if s > pos then
	 local unesc = escall:sub(pos, s - 1)
	 if brnest > 0 then
	    local anycom
	    if skip then
	       local comsub
	       comsub, anycom = unesc:sub(2):gsub(',', '|')
	       unesc = unesc:sub(1, 1) .. comsub
	    else
	       unesc, anycom = unesc:gsub(',', '|')
	    end
	    com[brnest] = com[brnest] + anycom
	 end
	 re = re .. unesc
	 skip = false
      end
      pos = e + 1
      if skip then
	 skip = false
      elseif not incc and what == '*' then
	 re = re .. '[^' .. dirsep .. ']*'
      elseif not incc and what == '?' then
	 re = re .. '[^' .. dirsep .. ']'
      elseif not incc and what == '[' then
	 re = re .. '(?![' .. dirsep .. '])['
	 incc = true
      elseif what == ']' then
	 re = re .. what
	 incc = false
      elseif not incc and what == '{' then
	 brnest = brnest + 1
	 com[brnest] = 0
	 brloc[brnest] = #re
	 re = re .. '(?:'
      elseif not incc and brnest > 0 and what == '}' then
	 if com[brnest] == 0 then
	    re = re:sub(1, brloc[brnest]) .. '\\{' .. re:sub(brloc[brnest] + 4)
	    re = re .. '\\}'
	 else
	    re = re .. ')'
	 end
	 brnest = brnest - 1
      else
	 re = re .. '\\' .. what
      end
   end
   re = re .. escall:sub(pos)
   while brnest > 0 do
      re = re:sub(1, brloc[brnest]) .. '\\{' .. re:sub(brloc[brnest] + 4)
      brnest = brnest - 1
   end
   -- let regex library detect mismatched []
   return '^' .. re .. '$'
end

-- this only applies a pattern to files in one directory
function dir_regex(dir, regex)
   if regex == nil then
      regex = dir
      dir = glib.get_current_dir()
   end
   if type(regex) == 'string' then
      local cf
      if glib.os ~= 'unix' then
	 -- probably unsafe to assume all non-UNIX are insensitive
	 -- but how else can it be determined w/o running tests?
	 cf = {'caseless'}
      end
      local msg
      regex, msg = glib.regex_new(regex, cf)
      if not regex then
	 return function() return nil end
      end
   end
   local d = glib.dir(dir)
   return function()
      while true do
	 local n = d()
	 if n == nil then return nil end
	 if regex:find(n) then
	    return n
	 end
      end
   end
end

-- this only applies a pattern to files in one directory
function dir_glob(dir, glob)
   if glob == nil then
      glob = dir
      dir = glib.get_current_dir()
   end
   return dir_regex(dir, glob_to_regex(glob))
end

-- this only works for relative paths, but allows pat to have directory
-- separators
-- there is no way to do absolute path patterns on Windows in any sane
-- portable manner
-- also, it's too much trouble to efficiently handle non-glob path elements
-- properly (i.e., access them directly instead of scanning the directory)
function relative_glob(path, pat)
   if not pat then
      pat = path
      path = glib.get_current_dir()
   end
   local cf
   if glib.os ~= 'unix' then
      -- probably unsafe to assume all non-UNIX are insensitive
      -- but how else can it be determined w/o running tests?
      cf = {'caseless'}
   end
   local rx = glib.regex_new(glob_to_regex(pat), cf, {'partial'})
   return coroutine.wrap(function()
      local function process_dir(p, match)
         local de
	 local di = glib.dir(p)
	 if di then
	    for de in di do
	       local fm
	       if match then fm = glib.build_filename(match, de) else fm = de end
	       local m = rx:find(fm)
	       if m then coroutine.yield(fm) end
	       if m ~= nil and rx:find(fm .. glib.dir_separator:sub(1,1)) ~= nil then
		  process_dir(glib.build_filename(p, de), fm)
	       end
	    end
	 end
      end
      process_dir(path, nil)
   end)
end

-- just expand curly braces in a shell-like manner
function shell_expand_braces(pat)
   local s
   local pref = {''}
   local entries = {{}}
   local com = {{0}}
   local nest = 1
   local o, c
   -- for each brace or comma, and its preceeding text...
   for o, c in glib.regex_new('((?:[^\\\\{},[]|\\\\.|\\[(?:[^\\\\\\]]|\\\\.)*\\])*)' ..
			      '([{},])'):gmatch(pat) do
      if c == '{' then
	 -- open brace: save prefix and start a new group
	 nest = nest + 1
	 entries[nest] = {}
	 pref[nest] = o
	 com[nest] = {0}
      elseif nest > 1 and c == ',' then
	 -- comma: tack prefix to any text accumulated for this group
	 -- entry so far.  This may be nothing, or more than one entry if
	 -- it contained nested brace expansion
	 local ocom = com[nest][1]
	 local ent = entries[nest]
	 local nent = #ent
	 if ocom ~= nent then
	    local i
	    for i = ocom + 1, nent do
	       ent[i] = ent[i] .. o
	    end
	 else
	    nent = nent + 1
	    ent[ocom + 1] = o
	 end
	 table.insert(com[nest], 1, nent)
      elseif nest > 1 and c == '}' then
	 -- end brace: tack prefix to any text accumulated for this group
	 -- entry so far.  This may be nothing, or more than one entry if
	 -- it contained nested brace expansion
	 local ocom = com[nest][1]
	 local ent = entries[nest]
	 local nent = #ent
	 local i
	 if ocom ~= nent then
	    for i = ocom + 1, nent do
	       ent[i] = ent[i] .. o
	    end
	 else
	    nent = nent + 1
	    ent[ocom + 1] = o
	 end
	 -- if there were no commas, restore open and close brace for all
	 -- text so far (due to above, at least one piece exists)
	 if ocom == 0 then
	    for i = 1, nent do
	       ent[i] = '{' .. ent[i] .. '}'
	    end
	 end
	 -- now, prefix all text with {'s prefix and then append to
	 -- all elements in parent group entry
	 local pre = pref[nest]
	 -- for easier debugging, clear out no-long-needed entries
	 entries[nest] = nil
	 pref[nest] = nil
	 com[nest] = nil
	 nest = nest - 1
	 local oent = entries[nest]
	 ocom = com[nest][1] + 1
	 local noent = #oent
	 if noent < ocom then
	    noent = noent + 1
	    oent[noent] = ''
	 end
	 for i = ocom, noent do
	    local j
	    local otxt = oent[ocom] .. pre
	    table.remove(oent, ocom)
	    for j = 1, nent do
	       table.insert(oent, otxt .. ent[j])
	    end
	 end
      end
   end
   -- now deal with unmatched open braces
   while nest > 1 do
      local ent = entries[nest]
      local nent = #ent
      local i
      local ocom = com[nest]
      local ncom = #ocom - 1
      -- prepend stripped { and its prefix
      local pre = pref[nest] .. '{'
      if ncom > 0 then
	 -- for comma entries, also tack on stripped comma
	 for i = 1, ocom[ncom] do
	    ent[i] = pre .. ent[i] .. ','
	 end
	 for i = ocom[ncom] + 1, ocom[1] do
	    ent[i] = ent[i] .. ','
	 end
	 -- next, merge comma groups
	 for i = 1, ncom do
	    local j, j1, k, k1, km
	    j1 = ocom[i + 1] + 1
	    k1 = ocom[i] + 1
	    km = #ent
	    -- create new last group by merging all text in
	    -- 2nd-to-last group (j1 .. k1 - 1) with last group (k1 .. km)
	    -- at same time, remove 2nd-to-last group
	    if km >= k1 then
	       for j = j1, ocom[i] do
		  for k = k1, km do
		     table.insert(ent, ent[j1] .. ent[k])
		  end
		  table.remove(ent, j1)
		  k1 = k1 - 1
		  km = km - 1
	       end
	       -- remove old last group
	       for k = k1, km do
		  table.remove(ent, k1)
	       end
	    end
	 end
      elseif nent > 0 then
	 for i = 1, nent do
	    ent[i] = pre .. ent[i]
	 end
      else
	 ent[1] = pre
      end
      -- now that all commas and braces are restored, merge with parent as
      -- if a close brace had occurred (but ignore prefix, since it's already
      -- been merged)
      entries[nest] = nil
      pref[nest] = nil
      com[nest] = nil
      nest = nest - 1
      local oent = entries[nest]
      ocom = com[nest][1] + 1
      local noent = #oent
      if noent < ocom then
	 noent = noent + 1
	 oent[noent] = ''
      end
      for i = ocom, noent do
	 local j
	 local otxt = oent[ocom]
	 table.remove(oent, ocom)
	 for j = 1, #ent do
	    table.insert(oent, otxt .. ent[j])
	 end
      end
   end
   -- finally, append any non-brace text at end to all entries and return
   local app = glib.regex_new('(?:[^\\\\{},[]|\\\\.|\\[(?:[^\\\\\\]]|\\\\.)*\\])*$'):match(pat)
   local ret = entries[1]
   if #ret == 0 then
      ret = {app}
   else
      local i
      for i = 1, #ret do
	 ret[i] = ret[i] .. app
      end
   end
   return ret
end	 
	    

-- here's one way to handle the const path issue: split off paths until a
-- potentially special char is found.  No special chars are allowed in
-- the "root" prefix (not enforced, but it won't work otherwise).
-- note that although it expands the braces shell-like, it still rejects
-- non-glob paths that do not exist
function glob(pat)
   local ent = shell_expand_braces(pat)
   local i, v
   return coroutine.wrap(function()
      for i, v in ipairs(ent) do
	 local s = 1
	 while true do
	    s = v:find('[*?{}%[%]\\]', s)
	    if not s or v:sub(s, s) ~= '\\' then break end
	    s = s + 2
	 end
	 if not s then
	    if exists(v) then
	       coroutine.yield(v)
	    end
	 else
	    local const = v:sub(1, s - 1):gsub('\\(.)', '%1')
	    local dir = glib.path_get_dirname(const)
	    local de
	    local var
	    if v:sub(s - 1, s - 1):match("[" .. glib.dir_separator .. "]") then
	       var = v:sub(s)
	    else
	       var = basename(v:sub(1, s - 1)) .. v:sub(s)
	    end
	    for de in relative_glob(const, var) do
	       coroutine.yield(glib.build_filename(const, de))
	    end
	 end
      end
   end)
end
