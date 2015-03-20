#!/usr/bin/env lua

-- Note: This test is meant to be run/examined manually, and really
-- only be run by me.  The best you can hope for on your own is to
-- check that it doesn't crash.
-- It is not meant to test if GLib works, but if the interface works, so
-- you shouldn't need to test it against your own version of GLib.

-- While it checks for GLib versions after 2.32, it assumes at least 2.32.

if arg and #arg > 0 then
    pat = arg[1]
    if pat == 'help' or pat == '--help' or pat == '-h' or #arg > 1 then
	print('Invoke with no parameters to run all tests.')
	print('Invoke with regex to run only sections matching regex.')
	print("Invoke with 'list' to just list sections.")
	print("Invoke with 'help', '--help', or '-h' to print this message.")
	print('Sections:\n')
	pat = 'list'
    end
else
    pat = ''
end

local function head(x)
    if pat == 'list' then
	print(x)
	return false
    end
    if x:find(pat) then
	print('\n\n*** ' .. x .. ' ***\n')
	return true
    end
    return false
end

glib = require 'glib'

if head("Version Information") then
  print(glib.version)
end
gver = tonumber((string.gsub(glib.version, "%.[^.]*$", "")))

if head("Standard Macros") then
  print(glib.os, glib.dir_separator, glib.searchpath_separator)
end

if head("Message Logging") then
  glib.log("message")
  glib.log("glib-test", "msg", "test message")
  glib.log("crit", "Critical message")
  glib.log("critical", "Critical message")
  glib.log("debug", "Debug message")
  -- glib.log("err", "Error message")  -- exits program
  -- glib.log("error", "Error message")  -- exits program
  glib.log("info", "Info message")
  glib.log("message", "Message")
  glib.log("msg", "Message")
  glib.log("warn", "Warning message")
  glib.log("warning", "Warning message")
  print(pcall(glib.log, "z", "w"))
end

if head("Character Set Conversion") then
  print(glib.convert('x', 'y', 'z'))
  print(pcall(glib.convert, nil, nil, nil, 'blah'))
  ss = "AsdáßðasD/./þüú¹²"
  print(glib.convert(ss, 'ascii', 'utf-8', '<unk>'))
  s = glib.convert(ss, "latin1", "utf-8")
  print("convert", s ~= ss, ss == glib.convert(s, "utf-8", "latin1"))
  f = glib.convert(nil, "latin1", "utf-8")
  s2 = ''
  for c in ss:gmatch('.') do
    s2 = s2 .. f(c)
  end
  s2 = s2 .. f()
  f = glib.convert(nil, "utf-8", "latin1")
  ss2 = ''
  for c in s2:gmatch('.') do
    ss2 = ss2 .. f(c)
  end
  ss2 = ss2 .. f()
  print("convert-s", s == s2, ss == ss2)
end

if head("Unicode Manipulation") then
  print(glib.validate(0xd800), glib.validate(0x10f000))
  print(glib.isalpha('a'), glib.xdigit_value('a'))
  print(glib.type('a'), glib.type(0xd800))
  print(glib.break_type('a'), glib.break_type(0xd800))
  print(glib.get_mirror_char('('), glib.get_mirror_char(40))
  if gver >= 2.30 then
    print(glib.get_script('ç'))
  end
  print(glib.utf8_sub(ss, 2, 5), glib.utf8_len(ss), glib.utf8_validate(ss))
  print(glib.utf8_validate(s))
  print(glib.utf8_strup(ss), glib.utf8_strdown(ss), glib.utf8_casefold(ss))
  print(glib.utf8_normalize(ss), #glib.utf8_normalize(ss), glib.utf8_normalize(ss, true), #glib.utf8_normalize(ss, true))
  print(glib.utf8_normalize(ss, false, true), #glib.utf8_normalize(ss, false, true), glib.utf8_normalize(ss, true, true), #glib.utf8_normalize(ss, true, true))
  print(glib.utf8_collate(ss, glib.utf8_normalize(ss)))
  print(glib.utf8_collate_key(ss), glib.utf8_collate_key_for_filename(ss))
  print(#ss, #glib.utf8_to_utf16(ss), #glib.utf8_to_ucs4(ss))
  print(glib.ucs4_to_utf8(glib.utf16_to_ucs4(glib.utf8_to_utf16(ss))) == ss)
  print(glib.to_utf8(41) == ')')
end

if head("Base64 Encoding") then
  print(glib.base64_encode(ss), glib.base64_decode(glib.base64_encode(ss)) == ss)
  f = glib.base64_encode()
  s = glib.base64_encode(ss)
  f2 = glib.base64_decode()
  s2 = ''
  ss2 = ''
  for c in ss:gmatch('.') do
    co = f(c)
    s2 = s2 .. co
    ss2 = ss2 .. f2(co)
  end
  co = f()
  s2 = s2 .. co
  ss2 = ss2 .. f2(co)
  ss2 = ss2 .. f2()
  -- for some reason, s ~= s2.  However, ss2 == ss, so it's OK
  print(ss2 == ss, s, s2)
end

if head("Data Checksums") then
  print(glib.md5sum(ss), glib.sha1sum(ss), glib.sha256sum(ss))
  print(#glib.sha256sum(ss, true))
  s = glib.sha1sum(ss, true)
  f = glib.sha1sum()
  for c in ss:gmatch('.') do
    f(c)
  end
  print(f(true) == s)
  f = glib.sha1sum()
  for c in ss:gmatch('.') do
    f(c)
  end
  print(f())
  print(f())
end

if gver >= 2.30 and head("Secure HMAC Digests") then
  key = 'hello'
  print(glib.md5hmac(key, ss), glib.sha1hmac(key, ss), glib.sha256hmac(key, ss))
  print(#glib.sha256hmac(key, ss, true))
  s = glib.sha1hmac(key, ss, true)
  f = glib.sha1hmac(key)
  for c in ss:gmatch('.') do
    f(c)
  end
  print(f(true) == s)
  print(f())
end

if head("Internationalization") then
  locale = os.setlocale("")
  print(locale)
  glib.link(".", locale, true)
  glib.link(".", "LC_MESSAGES", true)
  print(glib.textdomain())
  print(glib.textdomain("glib-test", glib.get_current_dir()))
  print(glib.textdomain("glib"))
  print(glib.textdomain("glib-test"))
  -- To test this properly, a translation file should be used
  print(_("hello"), Q_("blah|hello"), C_("blah2", "hello"))
  n = N_("hello2")
  nc = { NC_("blah", "hello2") }
  print(n, nc[1], nc[2])
  print(_(n), C_(nc[2], nc[1]))
  for i, v in ipairs{1, 2, 0, 5} do
      print(v, glib.ngettext("single", "plural", v))
  end
  if gver >= 2.28 then
    for i, v in ipairs(glib.get_locale_variants()) do
      print(i, v)
    end
  end
  for i, v in ipairs(glib.get_locale_variants("en_US.utf8")) do
    print(i, v)
  end
end

-- tested at same time as timers
h = head("Date and Time Functions")
if head("Timers") and h then
  t = glib.timer_new()
  t2 = glib.timer_new()
  t3 = glib.timer_new()
  t2:stop()
  print("sleeping...")
  glib.usleep(5e5)
  t:stop() t2:continue()
  print("again...")
  glib.sleep(0.3)
  t:continue()
  t3:start()
  print("again...")
  glib.sleep(0.5)
  print("awake!")
  print("timers", t:elapsed(), t2:elapsed(), t3:elapsed())
end

if head("Random Numbers") then
  for i = 1, 10 do
    print(glib.random(6), glib.random(), glib.random(100, 1000))
  end
  f = glib.rand_new{42, 17}
  print("seed 42, 17")
  for i = 1, 10 do
    print(f(6), f(), f(100, 1000))
  end
  f = glib.rand_new(345)
  r = {}
  for i = 1, 100 do
    table.insert(r, {f(6), f(), f(100, 1000)})
  end
  f = glib.rand_new(345)
  for i, v in ipairs(r) do
    nv = {f(6), f(), f(100, 1000)}
    for j, sv in ipairs(v) do
      if sv ~= nv[j] then
	print("mismatch " .. tostring(i))
      end
    end
  end
  a = {}
  for i = 1, 26 do
    a[i] = string.char(i + string.byte('a') - 1)
  end
  -- make random stable
  glib.random = f
  -- cmorris' shuffle()
  function shuffle(a)
    local i
    for i = 1, #a do
	local r = glib.random(#a)
	local t = a[i]
	a[i] = a[r]
	a[r] = t
    end
  end
  shuffle(a)
  for i, v in ipairs(a) do
    io.write(v)
  end
  io.write('\n')
  -- cmorris' choice()
  function choice(a)
    if #a == 0 then
	return nil
    end
    return a[glib.random(#a)];
  end
  print(choice(a))
  -- cmorris' sample()
  function sample(a, n)
    local b = {}
    local s = {}
    local i
    for i = 1, n do
	-- warning, this could take a while if n is near #a
	repeat
	    r = glib.random(#a)
	until not b[r]
	b[r] = true
	s[i] = a[r]
    end
    return s
  end
  print(unpack(sample(a, 7)))
end

if head("Miscellaneous Utility Functions") then
  print(glib.application_name("Test for lua-glib"), glib.prgname("glib-test"))
  print(glib.application_name(), glib.prgname())
  print(glib.application_name(), glib.prgname())
  print(glib.getenv("PATH"))
  print(glib.setenv("PATH", "." .. glib.searchpath_separator .. glib.getenv("PATH"), true))
  print(glib.getenv("PATH"))
  print(unpack(glib.listenv()))
  print(glib.get_user_name(), glib.get_real_name())
  for i, v in ipairs(glib.get_dir_name()) do
    d = glib.get_dir_name(v)
    if type(d) == 'table' then
      print(v, table.concat(d, glib.searchpath_separator))
    else
      print(v, d)
    end
  end
  print(glib.get_dir_name('xxx'))
  glib.setenv("HOME", "/var/tmp", true)
  print(glib.get_dir_name('home'))
  cwd = glib.get_current_dir()
  print(glib.get_host_name(), cwd)
  print(glib.path_is_absolute("hello"), glib.path_is_absolute(cwd))
  print(glib.path_split_root(cwd))
  print(glib.path_split_root('hello'))
  print(glib.path_get_basename(cwd),
        glib.path_get_dirname(cwd))
  print(glib.build_filename())
  print(glib.build_filename{'var', 'tmp'})
  print(glib.build_filename('var', 'tmp/x'))
  a = {}
  for i = 1, 1000 do
    table.insert(a, 'd')
  end
  fn = glib.build_filename(a)
  fp = glib.build_path(glib.dir_separator:sub(1, 1), a)
  print(#fn, #fp, fn == fp)
  print(glib.build_path(glib.searchpath_separator, 'var', 'tmp'))
  -- following shows that this is worhtless for pathlist generation, since
  -- blank paths can actually be significant
  print(glib.build_path(glib.searchpath_separator, '', 'tst', '', 'now', ''))
  print(table.concat({'', 'tst', '', 'now', ''}, glib.searchpath_separator))
  -- there is also no inverse operation
  function split_file(f)
    local res = {}
    local r
    r, f = glib.path_split_root(f)
    while f ~= '' do
	local b = glib.path_get_basename(f)
	table.insert(res, 1, b)
	if b == f then break end
	f = glib.path_get_dirname(f)
    end
    return r, res
  end
  root, path = split_file("//var/tmp")
  print(root, table.concat(path, '|'))
  root, path = split_file("")
  print(root, table.concat(path, '|'))
  root, path = split_file("hello//there")
  print(root, table.concat(path, '|'))
  if gver >= 2.30 then
    function pr_sizes(s)
      print(glib.format_size(s), glib.format_size(s, true),
            glib.format_size(s, false, true), glib.format_size(s, true, true))
    end
    pr_sizes(1e6)
    pr_sizes(1024*1024)
    pr_sizes(2^48)
    pr_sizes(2^60)
  end
  print(glib.find_program_in_path("more"))
  print(glib.find_program_in_path("qzmore"))
  a = {}
  for i = 1, 20 do
    a[i] = { glib.random(1, 15), i }
  end
  function ltelt(e1, e2)
    return e1[1] < e2[1]
  end
  function cmpelt(e1, e2)
    return e1[1] - e2[1]
  end
  b = {unpack(a)}
  c = {unpack(a)}
  table.sort(b, ltelt)
  glib.qsort(c, cmpelt)
  -- this table is to prove whether or not glib's sort is stable vs. lua's
  print("i", "a[i]", "c[i]", "cn[i]", "c=b", "bn[i]", "bn=cn")
  for i, v in ipairs(c) do
    print(i, a[i][1], v[1], v[2], b[i][1] == v[1], b[i][2], b[i][2] == v[2])
  end
  mt = {}
  mt.__sub = function(a, b) return #a - #b end
  a = {1}
  b = {0, 1}
  setmetatable(a, mt) setmetatable(b, mt)
  print(glib.cmp("a", "a\0"), glib.cmp(1, 2), glib.cmp(a, b))
  print(glib.cmp("b", "a"), glib.cmp(2, 1), glib.cmp(b, a))
  print(glib.cmp("a", "a"), glib.cmp(1, 1.0), glib.cmp(a, {0}))
end

if head("Spawning Processes") then
  -- It's impossible to portably pick commands to run, so just assume UNIX
  -- In fact, assume Linux (e.g. /etc/timezone is non-standardized) */
  p, msg = glib.spawn('cat /etc/issue')
  if not p then print(msg) end
  print(p:io_wait(true, true, true))
  print(p:status())
  if gver >= 2.34 then print(p:check_exit_status()) end
  r, o = p:wait()
  print(#o)
  print(p:io_wait(true, true, true))
  print(p:status())
  if gver >= 2.34 then print(p:check_exit_status()) end
  p = nil
  if gver >= 2.34 then
      p, msg = glib.spawn('false')
      if not p then print(msg) end
      p:wait()
      print(p:check_exit_status())
      p = nil
  end
  p, msg = glib.spawn{'cat', '/etc/timezone'}
  if not p then print(msg) end
  print(p:wait())
  function get_penv(t)
    local i, v, r
    r = {}
    for i, v in ipairs(t) do
      local e = glib.getenv(v)
      if e then r[v] = e end
    end
    return r
  end
  p, msg = glib.spawn{'sh', '-c', 'export', env = get_penv{"PATH", "ADA_INCLUDE_PATH"}}
  if not p then print(msg) end
  print(p:wait())
  p, msg = glib.spawn('sleep 20')
  glib.sleep(0.5)
  p:kill()
  print(p:wait())
  p, msg = glib.spawn{'cat', stdin = '/etc/issue'}
  if not p then print(msg) end
  r, s = p:wait()
  print(r, #s)
  p, msg = glib.spawn{cmd = 'cat /etc/issue', stdout = '/tmp/catout'}
  if not p then print(msg) end
  print(p:wait())
  os.remove('/tmp/catout')
  f = io.open('/etc/timezone')
  p, msg = glib.spawn{cmd = 'cat', stdin = f}
  if not p then print(msg) end
  f:close()
  print(p:wait())
  p, msg = glib.spawn{'sh', '-c', 'echo error >&2'}
  if not p then print(msg) end
  print(p:wait())
  p, msg = glib.spawn{'sh', '-c', 'echo error >&2', stderr = '!/tmp/err'}
  if not p then print(msg) end
  print(p:wait())
  os.remove('/tmp/err')
  -- bash and zsh are non-standard shells, and may not be everywhere
  p, msg = glib.spawn{cmd='/bin/bash', 'sh', '-c', 'echo \\"$0\\" $BASH_VERSION'}
  if not p then print(msg) end
  print(p:wait())
  p, msg = glib.spawn{cmd='/bin/zsh', 'sh', '-c', 'echo \\"$0\\" $ZSH_VERSION'}
  if not p then print(msg) end
  print(p:wait())
  p, msg = glib.spawn{'cat', stdin = true}
  p:write('hello, world!\n')
  p:write('hello again, world!\n')
  p:write('54 1e7 +23&')
  p:close()
  print(p:read(5))
  print("'" .. p:read() .. "'")
  print(p:read('*l'))
  print(p:read('*n', '*n', '*n'))
  print(p:wait())
  p, msg = glib.spawn('cat /etc/issue')
  nw = 0
  for l in p:lines() do
    for w in l:gmatch('%S+') do
      nw = nw + 1
    end
  end
  p:wait()
  print(nw)
end

if head("File Utilities") then
  x = glib.file_get("/etc/issue")
  print(glib.file_get("/zzz"))
  print(glib.file_set("/zzz", x))
  print(glib.file_set("issue.x", x))
  print(x == glib.file_get("issue.x"))
  print(x == io.open("/etc/issue"):read('*a'))
  os.remove('issue.x')
  os.execute('ln -sf /etc/issue issue.xx')
  os.execute('ln -sf issue.xy issue.xy')
  os.execute('ln -sf issue.xyz issue.xz')
  for i, s in ipairs{'/etc', '/etc/issue', '/bin/true', 'issue.xx', 'issue.xy', 'issue.xz', 'issue.xyz'} do
    print(s, glib.exists(s), glib.is_file(s), glib.is_dir(s), glib.is_symlink(s), glib.is_exec(s), glib.read_link(s))
  end
  os.remove('issue.xx')
  os.remove('issue.xy')
  os.remove('issue.xz')
  print(glib.mkstemp('/tmp/blah'))
  print(glib.mkstemp('/blahXXXXXX'))
  f, n = glib.mkstemp('/tmp/blahXXXXXX.txt')
  print(f, n)
  f:write('hello, world!\n')
  f:close()
  os.execute('cat ' .. n)
  os.remove(n)
  print(glib.open_tmp('/tmp/blah'))
  print(glib.open_tmp('blah'))
  f, n = glib.open_tmp('blahXXXXXX')
  print(f, n)
  f:write('hello, world!\n')
  f:close()
  os.execute('cat ' .. n)
  os.remove(n)
  print(glib.mkdir_with_parents('/x'))
  print(glib.mkdir_with_parents('xx/yy/zz'))
  um = glib.umask(0)
  if gver >= 2.30 then
    print(um, glib.mkdtemp('/xx/XXXXXX'), glib.mkdtemp('xx/XXXXXX', 'og-rx,+w'))
    glib.umask(um)
    for e in glib.dir('xx') do
      io.write(e .. ' ')
      for k, v in pairs(glib.stat(glib.build_filename('xx', e))) do
	  io.write(k .. '=' .. v .. ' ')
      end
      io.write('\n')
    end
    io.write('\n')
    print(glib.dir_make_tmp('/XXXXXX'))
    print(glib.dir_make_tmp('xxxxx'))
    d = glib.dir_make_tmp()
    print(d)
    print(glib.remove(d))
  end
  print(glib.remove('/bin'))
  -- this test will not work as intended with glib < 2.30
  print(glib.remove('xx'))
  print(glib.mkdir(glib.build_filename('xx', 'zz')))
  
  function rm_r(f)
      local ok, msg, err, gmsg
      if not glib.is_symlink(f) and glib.is_dir(f) then
	  local e
	  for e in glib.dir(f) do
	      ok, msg = rm_r(glib.build_filename(f, e))
	      if not ok and not err then
		  err = true
		  gmsg = msg
	      end
	  end
      end
      ok, msg = glib.remove(f)
      if not ok and not err then
	  err = true
	  gmsg = f .. ': ' .. msg
      end
      if err then
	  return false, gmsg
      else
	  return true
      end
  end
  glib.chmod('xx/yy', '-w')
  print(glib.can_read('xx/yy'))
  print(glib.can_write('xx/yy'))
  glib.chmod('xx/yy', '-rx')
  print(glib.can_read('/x'))
  print(glib.can_write('/'))
  print(glib.can_read('xx/yy'))
  glib.chmod('xx/yy', '+rx')
  print(rm_r('xx'))
  glib.chmod('xx/yy', 'u+w')
  print(rm_r('xx'))
  d = glib.get_current_dir()
  print(d)
  glib.chdir('/tmp')
  print(glib.get_current_dir())
  glib.chdir(d)
  print(glib.get_current_dir())
  glib.file_set('xx', 'abc')
  om, oa = glib.stat('xx', 'mtime', 'atime')
  print(om, oa)
  glib.utime('xx', oa - 100)
  print(glib.stat('xx', 'mtime', 'atime'))
  glib.utime('xx', nil, om - 100)
  print(glib.stat('xx', 'mtime', 'atime'))
  glib.utime('xx')
  print(glib.stat('xx', 'mtime', 'atime'))
  glib.remove('xx')
end
if head("URI Functions") then
  print(glib.uri_reserved_chars_allowed_in_path)
  print(glib.uri_reserved_chars_allowed_in_path_element)
  print(glib.uri_reserved_chars_allowed_in_userinfo)
  print(glib.uri_reserved_chars_generic_delimiters)
  print(glib.uri_reserved_chars_subcomponent_delimiters)
  print(glib.uri_parse_scheme('/x/y'))
  print(glib.uri_parse_scheme('host:blah'))
  print(glib.uri_escape_string('/hello thereß/'))
  print(glib.uri_escape_string('/hello thereß/', '/'))
  print(glib.uri_escape_string('/hello thereß/', nil, true))
  -- glib's unescape disallows %00
  print(glib.uri_unescape_string('%2Fhello+there%2F%00'))
  -- glib's unescape doesn't recognize + as space
  print(glib.uri_unescape_string('%2Fhello+there%2F') == '/hello+there/')
  print(glib.uri_unescape_string('%2Fhello+there%2F', '/'))
  -- URI list is a pretty worthless format
  for i, v in ipairs(glib.uri_list_extract_uris [[
#This is a comment
http://blah/z
actually, there are no format restrictions other than 'all on one line'

and blank lines are ignored.]]) do
     print(i, v)
  end
  t = glib.filename_to_uri(glib.get_current_dir())
  print(t, glib.filename_from_uri(t))
  t = glib.filename_to_uri(glib.get_current_dir(), glib.get_host_name())
  print(glib.filename_from_uri(t))
end
if head('Hostname Utilities') then
  o = 'aßdf'
  a = glib.hostname_to_ascii(o)
  print(a, glib.hostname_to_unicode(a), glib.hostname_to_unicode(a) == o)
  print(glib.hostname_is_non_ascii(o), glib.hostname_is_non_ascii(a))
  print(glib.hostname_is_ascii_encoded(a), glib.hostname_is_ascii_encoded('asdf'))
  print(glib.hostname_is_ip_address('::0'), glib.hostname_is_ip_address('127.0.0.1'))
  print(glib.hostname_is_ip_address(a))
end
if head('Shell-related Utilities') then
  -- shell_parse_argv does not expand $, glob, {}
  -- it also provides no means to find out which args need expansion or not
  -- by stripping out both types of quotes the same way
  for i, v in ipairs(glib.shell_parse_argv("hello 'arg1\\ x'\\\\\\''z' {a,b} $VAR \"$var\\\"\"")) do
  -- for jed: "
    print(i, '"' .. v .. '"')
  end
  -- glib quotes everything, even if unnecessary...
  print(glib.shell_quote("a'b\\c d"), glib.shell_quote("abcd"))
  print(glib.shell_unquote("'ab"))
  print(glib.shell_unquote(glib.shell_quote("a'b\\c d")))
end
if head('Perl-compatible Regular Expressions') then
  print(glib.regex_escape_string('^([abc].*\\s$x$'))
  for ri, rv in ipairs{{'([abc]*)c', {'caseless'}},
                       -- this pattern doesn't work for 'all' mode
                       {'([abc]{1,2})c', {'caseless'}},
                       {'([abc][abc]?)c', {'caseless'}, {'partial'}},
		       {'(?<hello>[abc])([abc])(c)', {'caseless'}},
		       {'.*'},
		       {'^'},
		       {'$'},
		       {'\n'},
		       {'(?<!ab)C'},
		       } do
    rx, msg = glib.regex_new(unpack(rv))
    if not rx then
      print(rv[1], msg)
    else
      print(rx:get_pattern(), rx:get_max_backref(), rx:get_capture_count(), rx:get_string_number('hello'))
      if gver >= 2.34 then print(rx:get_has_cr_or_lf()) end
      if gver >= 2.38 then print(rx:get_max_lookbehind()) end
      for i, v in ipairs(rx:get_compile_flags()) do
	print(i, v)
      end
      for i, v in ipairs(rx:get_match_flags()) do
	print(i, v)
      end
      ms = 'abcBacCabCbaBaCba'
      print(rx:find(ms))
      print(rx:find(ms, 1, {'all'}))
      s, e, m = rx:tfind(ms)
      print(s, e)
      if s then
	for i, v in ipairs(m) do print(i, v) end
      end
      s, e, m = rx:tfind(ms, 1, {'all'})
      print(s, e)
      if(s) then
	for i, v in ipairs(m) do print(i, v) end
      end
      print(rx:match(ms))
      print(rx:match(ms, 1, {'all'}))
      for a, b, c, d, e, f, g, h, i, j in rx:gmatch(ms) do
	if j then print(a, b, c, d, e, f, g, h, i, j)
	elseif i then print(a, b, c, d, e, f, g, h, i)
	elseif h then print(a, b, c, d, e, f, g, h)
	elseif g then print(a, b, c, d, e, f, g)
	elseif f then print(a, b, c, d, e, f)
	elseif e then print(a, b, c, d, e)
	elseif d then print(a, b, c, d)
	elseif c then print(a, b, c)
	elseif b then print(a, b)
	else print(a) end
      end
      for a, b, c, d, e, f, g, h, i, j in rx:gfind(ms) do
	if j then print(a, b, c, d, e, f, g, h, i, j)
	elseif i then print(a, b, c, d, e, f, g, h, i)
	elseif h then print(a, b, c, d, e, f, g, h)
	elseif g then print(a, b, c, d, e, f, g)
	elseif f then print(a, b, c, d, e, f)
	elseif e then print(a, b, c, d, e)
	elseif d then print(a, b, c, d)
	elseif c then print(a, b, c)
	elseif b then print(a, b)
	else print(a) end
      end
      for s, e, m in rx:gtfind(ms) do
	print(s, e)
	if s then
	  for i, v in ipairs(m) do print(i, v) end
	end
      end
    end
    function n(s, e, r)
      print(s, e, r)
      return true
    end
    print(rx:gsub(ms, 'zZ', 1, n))
  end
  rx = glib.regex_new('\\|(.?)\\|')
  for i, v in ipairs(rx:split('abc||def|!|ghi')) do
    print(i, v)
  end
  -- doesn't have to be a complicated regex
  rx = glib.regex_new(':')
  for i, v in ipairs(rx:split(glib.getenv('PATH'))) do
    io.write(v .. ' ')
  end
  io.write('\n')
end
if head('Simple XML Subset Parser') then
  print(glib.markup_escape_text('abc<>&xyz'))
  e = glib.markup_escape_text
  pi = '<purchase>' ..
       '<store>' .. e('The Store & Company') .. '</store>' ..
       '<item>' .. e('An Item') .. '</item>' ..
       '</purchase>'
  print(pi)
  -- only allocate/parse once
  local bool_rx = glib.regex_new('^(false|f|no|n|0)|(true|t|yes|y|1)$', {'caseless'})
  -- could pass in el_name for better error message
  function collect_attrs(attr_names, attr_vals, req_parms)
    -- return attr=value table
    local attrs = {}
    -- put attrs i table, checking for duplicates
    local i, v
    for i, v in ipairs(attr_names) do
      if attrs[v] then return nil, "duplicate attribute " .. v end
      attrs[v] = attr_vals[i]
    end
    -- parse values, ensuring they are in req_parms as well
    local n
    for n, v in pairs(attrs) do
      local isreq = req_parms[n]
      if not isreq then return nil, "unknown attribute " .. n end
      if isreq:sub(1, 1) == '?' then isreq = isreq:sub(2) end
      if isreq == 'bool' then
        local f = bool_rx:match(v)
	if not f then return nil, "invalid boolean " .. n end
	attrs[n] = f == ''
      end
    end
    -- ensure that only optional values are missing
    for n, v in pairs(req_parms) do
      if v:sub(1, 1) ~= '?' and attrs[n] == nil then
	return nil, "missing attr " .. n
      end
    end
    return attrs
  end
  function counter()
    local count = 0
    return {
      start_element = function() count = count + 1 end,
      pop = function() return count end
    }
  end
  function pr_start_el(ctx, n, an, av)
    print(ctx:get_element(), ctx:get_position())
    pr_el_stack(ctx)
    print('+' .. n)
    for i, v in ipairs(an) do
	print(v .. ' = "' .. av[i] .. '"')
    end
    if n == 'error' then return 'Got error node' end
    if n == 'test' then
      attrs, msg = collect_attrs(an, av,
				{a='str', b='bool', c='?bool'})
      if not attrs then print("error: " .. msg)
      else for k, v in pairs(attrs) do print(k .. '=' .. tostring(v)) end end
    end
    if n == 'count' then
      return counter()
    end
  end
  function pr_end_el(ctx, n, pop)
    print(ctx:get_element(), ctx:get_position())
    pr_el_stack(ctx)
    print('-' .. n)
    if pop then print(pop()) end
  end
  function pr_text(ctx, text)
    print(ctx:get_element(), ctx:get_position())
    pr_el_stack(ctx)
    print('t' .. text)
  end
  function pr_passthrough(ctx, text)
    print(ctx:get_element(), ctx:get_position())
    pr_el_stack(ctx)
    print('p' .. text)
  end
  function pr_error(ctx, text)
    print(ctx:get_element(), ctx:get_position())
    pr_el_stack(ctx)
    print('!' .. text)
  end
  function pr_el_stack(ctx)
    local i, v
    for i, v in ipairs(ctx:get_element_stack()) do
      print(i, v)
    end
  end

  mpc = glib.markup_parse_context_new {
    start_element = pr_start_el,
    end_element = pr_end_el,
    text = pr_text,
    passthrough = pr_passthrough,
    error = pr_error,
    prefix_error_position = true,
    treat_cdata_as_text = true
  }
  mpc:parse(pi)
  mpc:parse('<test a="y" b="1"/>')
  mpc:parse('<test a="y" b="1" b="2"/>')
  mpc:parse('<test a="y" b="1" c="n"/>')
  mpc:parse('<test a="y" b="1" z="n"/>')
  mpc:parse('<test a="y" b="1" c="x"/>')
  mpc:parse('<count><a/><b/><c/><d/></count>')
  mpc:parse('<error/>')
  -- mpc:end_parse()  -- mpc is now invalid due to error
end
if head('Key-value file parser') then
  kf = glib.key_file_new()
  print(kf:set_comment('Testing'))
  kf:set('Group 1', 'Key 1', 'A test string')
  -- can't set comment for individual xlation
  print(kf:set_comment('nlnd == neverland', 'Group 1', 'Key 1[nlnd]'))
  print(kf:set_comment('nlnd == neverland', 'Group 1', 'Key 1'))
  kf:set('Group 1', 'Key 1', 'A test string in nlnd', 'nlnd')
  print(kf:set_comment('Comment before create', 'Group 2'))
  kf:set_boolean('Group 2', 'Key 2', true)
  kf:set_number('Group 2', 'Key 3', 15)
  kf:set_number('Group 2', 'Key 4', 17.25)
  kf:set_number('Group 3', 'Key 5', -7)
  print(kf:set_comment('Comment after create', 'Group 3'))
  kf:set_list('Group 4', 'Key 1', {'string 1', 'string 2;,', 'string 3"<>;'})
  kf:set_list_separator(',')
  kf:set_list('Group 4', 'Key 1', {'string 1', 'string 2;,', 'string 3"<>,'}, 'com')
  kf:set_list_separator(';')
  print(kf:raw_get('Group 4', 'Key 1'))
  kf:raw_set('Group 1', 'Key 2', kf:raw_get('Group 4', 'Key 1'))
  kf:set_boolean_list('Group 4', 'Key 2', {true, false, true, true, false})
  kf:set_number_list('Group 4', 'Key 3', {15000, 2^32, 2^49, -3})
  print(kf:to_data())
  glib.file_set('xx', kf:to_data())
  kf2 = glib.key_file_new()
  -- FIXME: add tests for 2nd param of true or {'dir1', ...}
  kf2:load_from_file('xx', false, true, true)
  glib.remove('xx')
  kf3 = glib.key_file_new()
  kf3:load_from_data(kf:to_data(), true, true)
  kf:save_to_file('xx')
  kf4 = glib.key_file_new()
  kf4:load_from_file('xx', false, true, true)
  glib.remove('xx')
  -- comment after create has blank line after it in kf, but not kf2-kf4
  print(kf2:to_data() == kf3:to_data(), kf:to_data() == kf3:to_data(),
        kf4:to_data() == kf3:to_data())
  print(kf2:get('Group 1', 'Key 1') == 'A test string')
  print(kf2:get('Group 1', 'Key 1', 'nlnd') == 'A test string in nlnd')
  print(kf2:get('Group 1', 'Key 1', 'zzz') == 'A test string')
  print(kf2:get_boolean('Group 2', 'Key 2'))
  print(kf2:get_boolean('Group 2', 'Key 3'))
  print(kf2:get_number('Group 2', 'Key 4'))
  -- buggy glib writes escaped separators, but doesn't parse them correctly
  for i, v in ipairs(kf2:get_list('Group 4', 'Key 1')) do
    print(i, v)
  end
  kf2:set_list_separator(',')
  for i, v in ipairs(kf2:get_list('Group 4', 'Key 1', 'com')) do
    print(i, v)
  end
  kf2:set_list_separator(';')
  for i, v in ipairs(kf2:get_boolean_list('Group 4', 'Key 2')) do
    print(i, v)
  end
  print(kf2:get_boolean_list('Group 4', 'Key 1'))
  for i, v in ipairs(kf2:get_number_list('Group 4', 'Key 3')) do
    print(i, v)
  end
  print(kf2:get_number_list('Group 4', 'Key 1'))
  print(kf2:get_start_group())
  for i, v in ipairs(kf2:get_groups()) do
    print(i, v)
    for ki, kv in ipairs(kf2:get_keys(v)) do
      print(' ' .. kv)
    end
  end
  print(kf:has_group('Group 1'))
  print(kf:has_group('Group 5'))
  print(kf:has_key('Group 1', 'Key 1'))
  print(kf:has_key('Group 1', 'Key 4'))
  print(kf:has_key('Group 5', 'Key 1'))
  -- Apparently group comments are read back with leading #
  -- what a buggy piece of crap
  print(kf:get_comment('Group 3'))
  print(kf:get_comment('Group 1', 'Key 1'))
  print(kf2:remove_comment('Group 5'))
  print(kf2:remove_comment())
  print(kf2:remove_comment('Group 1', 'Key 1'))
  print(kf2:remove_comment('Group 1', 'Key 1'))
  print(kf2:remove_comment('Group 1', 'Key 5'))
  print(kf3:remove('Group 2'))
  print(kf3:remove('Group 5'))
  print(kf3:remove('Group 1', 'Key 1'))
  print(kf3:remove('Group 1', 'Key 1'))
end
if head('Bookmark file parser') then
  bmf=[[
<?xml version="1.0"?>
<!DOCTYPE xbel PUBLIC
  "+//IDN python.org//DTD XML Bookmark Exchange Language 1.0//EN//XML"
  "http://www.python.org/topics/xml/dtds/xbel-1.0.dtd">
<xbel version="1.0"
      xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info"
      xmlns:bookmark="http://www.freedesktop.org/standards/desktop-bookmarks">
  <bookmark href="file:///home/ebassi/bookmark-spec/bookmark-spec.xml">
    <title>Desktop Bookmarks Spec</title>
    <info>
      <metadata owner="http://freedesktop.org">
        <mime:mime-type>text/xml</mime:mime-type>
        <bookmark:applications>
          <bookmark:application name="GEdit" count="2" exec="gedit %u" timestamp="1115726763"/>
          <bookmark:application name="GViM" count="7" exec="gvim %f" timestamp="1115726812"/>
        </bookmark:applications>
        <bookmark:groups>
          <bookmark:group>Editors</bookmark:group>
        </bookmark:groups>
      </metadata>
    </info>
  </bookmark>
</xbel>
]]
  xbel = glib.bookmark_file_new()
  print(xbel:to_data())
  print(xbel:load_from_data(bmf))
  print(#xbel)
  -- FIXME: add tests for all the other crap in this group I'll never use
end
