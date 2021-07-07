Module ``glib``
===============
.. _glib:

This package wraps the GLib library fairly thinly.

Unlike other lua-glib implementations, this is not meant to be a stepping stone for GTK+ support. It is meant to be a portability and utility library. There are other projects which provide support for GTK+ and other various derivatives of GLib.

Some features this library provides that other wrappers with similar scope don't are:

-  132 functions, 10 variables, 6 custom datatypes (adding 103 more functions as type methods), all documented using LuaDoc. Having the GLib docs on hand helps, but is not strictly necessary. Documentation is organized into mostly the same sections as the GLib documentation.
-  Streaming support where glib has it (e.g. conversion, checksums). This means that rather than requiring all input at once, it can be fed in piece-wise. For example, see `\_convert\_`_               .
-  Improved process spawn support, including redirection to/from lua “native” files and asynchronous lua readers and writers. See `spawn`_           and `process`_                   .
-  Global functions for gettext support (e.g. `\_`_       ())

The specific version against which this was developed was 2.32.4; I have scanned the documentation for added symbols, and it should compile as far back as version 2.26 with a few minor missing features (search for “available with GLib” or “ignored with GLib”). The reason 2.26 was chosen is that it is the oldest version permitted with the GLIB_VERSION_MIN_REQUIRED macro, even though I could've gone as low as 2.18 without significant loss of functionality. I have also in the mean time added a few
bits from versions up to 2.42.2, and updated compilability to 2.68.3.

The sections which are mostly supported are Version Information, Character Set Conversion (including streaming), Unicode Manipulation (skipping the low-level support functions and others which would really need low-level Lua Unicode support), Base64 Encoding (including streaming), Data Checksums (including streaming), Secure HMAC Digests (including streaming), Internationalization (including gettext macros, but excluding some of the low-level support functions), Miscellaneous Utility Functions
(except for bit operations, which really need to be added to lua-bit, and a few other low-level/internal-use type functions), Timers, Spawning Processes (including some extra features), File Utilities (except a few MS library compatibility functions and memory mapped files), URI Functions, Hostname Utilities, Shell-related Utilities, Perl-compatible regular expressions, Simle XML Subset Parser (without vararg functions since building varargs generically is not possible), Key-value file parser,
and Bookmark file parser.

The only Standard Macros supported are the OS and path separator macros. Date and Time Functions are mostly unsupported; the only one which could not be replaced by a native Lua time library is usleep, which is supported. The GTimeZone and GDateTime sections are not supported for the same reason.

No support is provided for Type Conversion Macros, Byte Order Macros, Numerical Definitions, or Miscellaneous Macros, as they are all either too low-level or C-specific. No support is provided for Atomic Operations, Threads, Thread Pools, or Asynchronous queues; use a Lua-specific threading module instead (such as Lanes). No support is provided for The Main Event Loop, as its utility versus implementation effort seems low. No support is provided for Dynamic Loading of Modules, because lua
already does that. No support is provided for Memory Allocation or Memory Slices, since you shouldn't be doing that in Lua. IO Channels also seem below my minimum utility-to-effort ratio. There is no direct support for the Error Reporting, Message Output, and Debugging Functions. There is no support for replacing the log handlers or setting the fatality flags in log messages, although that may come some day. The String Utility Functions are C-specific, and not supported. The Hook Functions seem
useless for Lua. The Lexical Scanner is not very configurable and hard to bind to Lua; use a made-for-Lua scanner instead like Lpeg. No support is provided for the Commandline option parser, as adapting it to Lua would remove most of its convenience and there are plenty of other similar libraries for lua. The Glob-style pattern matching is too simplistic and can easily be emulated using regex-style patterns (for example, see glob.lua, which should be packaged with this). The UNIX-specific and
Windows-specific functions are not supported, since such blatantly non-portable functions should not be used. The Testing framework is not supported, because a Lua-specific framework would be more suited to the task. None of the GLib Data Types are supported, although there may be merit in eventually supporting the GVariant type somewhat.

Eventually, this may be split into multiple modules, so that uselses stuff can be removed. However, removing useless stuff from GLib is not easy, so having Lua bindings for what's there is not necessarily harmful.

This package was split off from my odin-lua project, so it uses an Odinfile to build (and in fact requires itself to be present for odin-lua to work, so it needs to be compiled by hand the first time anyway). It's just one C file, though, so it shouldn't be too hard to make a shared object out of it, linked to the glib and lua libraries. For example, on amd64 Linux (may need to change -fPIC on other architectures):

::

   gcc -O2 -fPIC `pkg-config glib-2.0 --cflags --libs` -llua -shared -o glib.so lua-glib.c

Or you could use Lake:

::

   lake NEEDS=gtk -lua lua-glib.c

This documentation was built as follows (again, this is in the Odinfile):

::

    ldoc.lua -p lua-glib -o lua-glib -d . -f discount -t 'Lua GLib Library' lua-glib.c

Using `ldoc-1.2.0 <http://stevedonovan.github.com/ldoc>`__, with a patch to escape underscores in in-line references:

::

   --- ldoc/markup.lua
   +++ ldoc/markup.lua
   @@ -42,6 +42,9 @@
       if backtick_references then
          res  = res:gsub('`([^`]+)`',function(name)
             local ref,err = markup.process_reference(name)
   +         if not plain and ref then -- a nastiness with markdown.lua and underscores
   +            name = name:gsub('_','\\_')
   +         end
             if ref then
                return ('<a href="%s">%s</a> '):format(ldoc.href(ref),name)
             else

And `lua-discount <http://asbradbury.org/projects/lua-discount/>`__, changed to use the system discount library:

::

   rm -f *.h
   make DISCOUNT_OBJS= LIBS=-lmarkdown

The `discount <http://www.pell.portland.or.us/~orc/Code/discount/>`__ version I used was 2.1.5a, with everything enabled, and compiled with -fPIC to enable linking with shared libraries.

Note that since LDoc does not support error return sections, I have used exception sections (@raise) instead.

For Bitbucket, I have converted this documentation to rst using pandoc and a bit of filtering. See the Lua filtering code in Odinfile; this almost certainly needs Odin for best results. I chose rst because markdown doesn't do tables (at least not in a way that's compatible with anything pandoc can produce). Originally, I used textile because github appears to display markup as ASCII if it takes too long to process, and only textile seemed to be fast enough. However, textile output is broken on
bitbucket and it seemed easier to just use the rst output I had already tweaked.

Questions/comments to darktjm@gmail.com.

`Version Information`_
----------------------

====================== ====================
`version`_             GLib version string.
====================== ====================

`Standard Macros`_
------------------

================================================ ====================
`os`_                                            Operating system.
`dir_separator`_                                 Directory separator.
`searchpath_separator`_                          Path list separator
================================================ ====================

`Message Logging`_
------------------

======================================= ==========================
`log`_ ([domain][, level], msg)         Log a message, GLib-style.
======================================= ==========================

`Character Set Conversion`_
---------------------------

======================================================== =========================================================================
`\_convert_`_ ([str])                                    Stream character conversion function returned by `convert`_             .
`convert`_ ([str[, to[, from[, fallback]]]])             Convert strings from one character set to another.
======================================================== =========================================================================

`Unicode Manipulation`_
-----------------------

====================================================================== =========================================================================
`validate`_ (c)                                                        Check if unicode character is valid.
`isalpha`_ (c)                                                         Check if Unicode character is alphabetic.
`iscntrl`_ (c)                                                         Check if Unicode character is a control character.
`isdefined`_ (c)                                                       Check if Unicode character is explicitly defined in the Unicode standard.
`isdigit`_ (c)                                                         Check if Unicode character is a decimal digit.
`isgraph`_ (c)                                                         Check if Unicode character is a visible, printable character.
`islower`_ (c)                                                         Check if Unicode character is a lower-case alphabetic character.
`ismark`_ (c)                                                          Check if Unicode character is a mark.
`isprint`_ (c)                                                         Check if Unicode character is printable.
`ispunct`_ (c)                                                         Check if Unicode character is a punctuation or symbol character.
`isspace`_ (c)                                                         Check if Unicode character is whitespace.
`istitle`_ (c)                                                         Check if Unicode character is titlecase.
`isupper`_ (c)                                                         Check if Unicode character is upper-case.
`isxdigit`_ (c)                                                        Check if Unicode character is hexadecimal digit.
`iswide`_ (c)                                                          Check if Unicode character is wide.
`iswide_cjk`_ (c)                                                      Check if Unicode character is wide in legacy East Asian locales.
`iszerowidth`_ (c)                                                     Check if Unicode character is zero-width.
`toupper`_ (c)                                                         Convert Unicode character to upper-case.
`tolower`_ (c)                                                         Convert Unicode character to lower-case.
`totitle`_ (c)                                                         Convert Unicode character to title case.
`digit_value`_ (c)                                                     Convert digit to its numeric value.
`xdigit_value`_ (c)                                                    Convert hexadecimal digit to its numeric value.
`type`_ (c)                                                            Find Unicode character class.
`break_type`_ (c)                                                      Find Unicode character's line break classification.
`get_mirror_char`_ (c)                                                 Find Unicode mirroring character.
`get_script`_ (c)                                                      Find ISO 15924 script for a Unicode character.
`utf8_sub`_ (s[, first[, last]])                                       Obtain a substring of a utf-8-encoded string.
`utf8_len`_ (s)                                                        Obtain the number of code points in a utf-8-encoded string.
`utf8_validate`_ (s)                                                   Check if a string is valid UTF-8.
`utf8_strup`_ (s)                                                      Convert UTF-8 string to upper-case.
`utf8_strdown`_ (s)                                                    Convert UTF-8 string to lower-case.
`utf8_casefold`_ (s)                                                   Convert UTF-8 string to case-independent form.
`utf8_normalize`_ (s[, compose[, compatible]])                         Perform standard Unicode normalization on a UTF-8 string.
`utf8_collate`_ (s1, s2)                                               Compare UTF-8 strings for collation.
`utf8_collate_key`_ (s)                                                Create a comparison key for a UTF-8 string.
`utf8_collate_key_for_filename`_ (s)                                   Create a comparison key for a UTF-8 filename string.
`utf8_to_utf16`_ (s)                                                   Convert a UTF-8 string to UTF-16.
`utf8_to_ucs4`_ (s)                                                    Convert a UTF-8 string to UCS-4.
`utf16_to_utf8`_ (s)                                                   Convert a UTF-16 string to UTF-8.
`utf16_to_ucs4`_ (s)                                                   Convert a UTF-16 string to UCS-4.
`ucs4_to_utf16`_ (s)                                                   Convert a UCS-4 string to UTF-16.
`ucs4_to_utf8`_ (s)                                                    Convert a UCS-4 string to UTF-8.
`to_utf8`_ (c)                                                         Convert a UCS-4 code point to UTF-8.
====================================================================== =========================================================================

`Base64 Encoding`_
------------------

============================================= ================================================================================
`\_base64_encode_`_ ([s])                     Stream Base64-encoding function returned by `base64_encode`_                   .
`base64_encode`_ ([s])                        Base64-encode a string.
`\_base64_decode_`_ ([s])                     Stream Base64-decoding function returned by `base64_decode`_                   .
`base64_decode`_ ([s])                        Base64-decode a string.
============================================= ================================================================================

`Data Checksums`_
-----------------

======================================= ===============================================
`\_sum_`_ ([s][, raw])                  Stream checksum/hash calculation function type.
`md5sum`_ ([s[, raw]])                  Compute MD5 checksum of a string.
`sha1sum`_ ([s[, raw]])                 Compute SHA1 checksum of a string.
`sha256sum`_ ([s[, raw]])               Compute SHA256 checksum of a string.
======================================= ===============================================

`Secure HMAC Digests`_
----------------------

============================================== ========================================
`\_hmac_`_ ([s][, raw])                        Stream HMAC calculation function.
`md5hmac`_ (key[, s[, raw]])                   Compute secure HMAC digest using MD5.
`sha1hmac`_ (key[, s[, raw]])                  Compute secure HMAC digest using SHA1.
`sha256hmac`_ (key[, s[, raw]])                Compute secure HMAC digest using SHA256.
============================================== ========================================

`Internationalization`_
-----------------------

=========================================================== =====================================================
`textdomain`_ ([domain[, path[, encoding]]])                Set or query text message database location.
`\_`_ (s)                                                   Replace text with its translation.
`Q_`_ (s)                                                   Replace text and context with its translation.
`C_`_ (c, s)                                                Replace text and context with its translation.
`N_`_ (s)                                                   Mark text for translation.
`NC_`_ (c, s)                                               Mark text for translation with context.
`ngettext`_ (singular, plural, n)                           Replace text with its number-appropriate translation.
`get_locale_variants`_ ([locale])                           Obtain list of valid locale names.
=========================================================== =====================================================

`Date and Time Functions`_
--------------------------

======================== ========================================
`sleep`_ (t)             Suspend execution for some seconds.
`usleep`_ (t)            Suspend execution for some microseconds.
======================== ========================================

`Random Numbers`_
-----------------

==================================== =====================================================
`random`_ ([low[, high]])            Obtain a psuedorandom number.
`rand_new`_ ([seed])                 Obtain a psuedorandom number generator, given a seed.
==================================== =====================================================

`Miscellaneous Utility Functions`_
----------------------------------

================================================= =================================================
`application_name`_ ([name])                      Set or get localized application name.
`prgname`_ ([name])                               Set or get program name.
`getenv`_ (name)                                  Get environment variable value.
`setenv`_ (name, value[, replace])                Set environment variable value.
`unsetenv`_ (name)                                Remove environment variable.
`listenv`_ ()                                     Obtain names of all environment variables.
`get_user_name`_ ()                               Obtain system user name for current user.
`get_real_name`_ ()                               Obtain full user name for current user.
`get_dir_name`_ (d)                               Obtain a standard directory name.
`get_host_name`_ ()                               Obtain current host name.
`get_current_dir`_ ()                             Obtain current working directory.
`path_is_absolute`_ (d)                           Check if a directory is absolute.
`path_split_root`_ (d)                            Split the root part from a path.
`path_get_basename`_ (d)                          Obtain the last element of a path.
`path_get_dirname`_ (d)                           Obtain all but the last element of a path.
`build_filename`_ (...)                           Construct a file name from its path constituents.
`build_path`_ (sep, ...)                          Construct a path from its constituents.
`path_canonicalize`_ (f)                          Canonicalize a path name.
`qsort`_ (t[, cmp])                               Sort a table using a stable quicksort algorithm.
`cmp`_ (a, b)                                     Compare two objects.
================================================= =================================================

`Timers`_
---------

============================= ==============================
`timer_new`_ ()               Create a stopwatch-like timer.
============================= ==============================

Class `timer`_
--------------

======================================= =========================================
`timer:start`_ ()                       Start or reset the timer.
`timer:stop`_ ()                        Stop the timer if it is running.
`timer:continue`_ ()                    Resume the timer if it is stopped.
`timer:elapsed`_ ()                     Return the amount of time counted so far.
======================================= =========================================

`Spawning Processes`_
---------------------

========================= =============================
`spawn`_ (args)           Run a command asynchronously.
========================= =============================

Class `process`_
----------------

============================================================================= =======================================================================
`process:read_ready`_ (...)                                                   Check if input is available from process standard output.
`process:read_err_ready`_ (...)                                               Check if input is available from process standard error.
`process:read`_ (...)                                                         Read data from a process' standard output.
`process:read_err`_ (...)                                                     Read data from a process' standard error.
`process:lines`_ ()                                                           Return an iterator which reads lines from the process' standard output.
`process:lines_err`_ ()                                                       Return an iterator which reads lines from the process' standard error.
`process:write_ready`_ ()                                                     Check if writing to the process' standard input will block.
`process:write`_ (...)                                                        Write to a process' standard input.
`process:close`_ ()                                                           Close the process' standard input channel.
`process:io_wait`_ ([check_in[, check_out[, check_err]]])                     Check for process activity.
`process:pid`_ ()                                                             Return the glib process ID for the process.
`process:status`_ ()                                                          Return the status of the running process.
`process:check_exit_status`_ ()                                               Check if the process return code was an error.
`process:wait`_ ()                                                            Wait for process termination and clean up.
============================================================================= =======================================================================

`File Utilities`_
-----------------

=========================================================== ========================================================================
`file_get`_ (name)                                          Return contents of a file as a string.
`file_set`_ (name, contents)                                Set contents of a file to a string.
`is_file`_ (name)                                           Test if the given path points to a file.
`is_dir`_ (name)                                            Test if the given path points to a directory.
`is_symlink`_ (name)                                        Test if the given path points to a symbolic link.
`is_exec`_ (name)                                           Test if the given path points to an executable file.
`exists`_ (name)                                            Test if the given path points to a file or directory.
`umask`_ ([mask])                                           Change default file and directory creation permissions mask.
`mkstemp`_ (tmpl[, perm])                                   Create a unique temporary file from a pattern.
`open_tmp`_ ([tmpl])                                        Create a unique temporary file in the standard temporary directory.
`read_link`_ (name)                                         Read the contents of a soft link.
`mkdir_with_parents`_ (name[, mode])                        Create a directory and any required parent directories.
`mkdtemp`_ (tmpl[, mode])                                   Create a unique tempoarary directory from a pattern.
`dir_make_tmp`_ ([tmpl])                                    Create a unique temporary directory in the standard temporary directory.
`dir`_ (d)                                                  Returns an iterator which lists entries in a directory.
`rename`_ (old, new)                                        Rename a file sytem entity.
`mkdir`_ (name[, mode])                                     Create a directory.
`stat`_ (name[, fields])                                    Retrieve information on a file system entry.
`remove`_ (name)                                            Remove a file sytem entity.
`chmod`_ (name, perm)                                       Change filesystem entry permissions.
`can_read`_ (name)                                          Test if fileystem object can be read.
`can_write`_ (name)                                         Test if fileystem object can be written to.
`chdir`_ (dir)                                              Change current working directory.
`utime`_ (name[, atime[, mtime]])                           Change timestamp on filesystem object.
`link`_ (target, name[, soft])                              Create a link.
=========================================================== ========================================================================

`URI Functions`_
----------------

============================================================================================ ========================================================================
`uri_reserved_chars_allowed_in_path`_                                                        Allowed characters in a path.
`uri_reserved_chars_allowed_in_path_element`_                                                Allowed characters in path elements.
`uri_reserved_chars_allowed_in_userinfo`_                                                    Allowed characters in userinfo (RFC 3986).
`uri_reserved_chars_generic_delimiters`_                                                     Generic delimiter characters (RFC 3986).
`uri_reserved_chars_subcomponent_delimiters`_                                                Subcomponent delimiter characters (RFC 3986).
`uri_parse_scheme`_ (uri)                                                                    Extract scheme from URI.
`uri_escape_string`_ (s[, allow[, utf8]])                                                    Escapes a string for use in a URI.
`uri_unescape_string`_ (s[, illegal])                                                        Unescapes an escaped string.
`uri_list_extract_uris`_ (list)                                                              Splits an URI list conforming to the text/uri-list MIME type (RFC 2483).
`filename_from_uri`_ (uri)                                                                   Converts an ASCII-encoded URI to a local filename.
`filename_to_uri`_ (file[, host])                                                            Converts an absolute filename to an escaped ASCII-encoded URI.
============================================================================================ ========================================================================

`Hostname Utilities`_
---------------------

===================================================================== ===============================================================
`hostname_to_ascii`_ (hostname)                                       Convert a host name to its canonical ASCII form.
`hostname_to_unicode`_ (hostname)                                     Convert a host name to its canonical Unicode form.
`hostname_is_non_ascii`_ (hostname)                                   Check if a host name contains Unicode characters.
`hostname_is_ascii_encoded`_ (hostname)                               Check if a host name contains ASCII-encoded Unicode characters.
`hostname_is_ip_address`_ (hostname)                                  Check if a string is an IPv4 or IPv6 numeric address.
===================================================================== ===============================================================

`Shell-related Utilities`_
--------------------------

================================================== ==============================================================================================
`shell_parse_argv`_ (cmdline)                      Parse a command line into an argument vector, but without variable and glob pattern expansion.
`shell_quote`_ (s)                                 Quote a string so it is interpreted unmodified as a shell argument.
`shell_unquote`_ (s)                               Unquote a string quoted for use as a shell argument.
================================================== ==============================================================================================

`Perl-compatible Regular Expressions`_
--------------------------------------

======================================================== ============================================================
`regex_new`_ (pattern[, cflags[, mflags]])               Compile a regular expression for use in matching functions.
`regex_escape_string`_ (s)                               Escapes a string so it is a literal in a regular expression.
======================================================== ============================================================

Class `regex`_
--------------

============================================================== ================================================================================
`regex:get_pattern`_ ()                                        Get the pattern string used to create this regex.
`regex:get_max_backref`_ ()                                    Get the highest back reference in the pattern.
`regex:get_has_cr_or_lf`_ ()                                   Check if pattern contains explicit CR or LF references.
`regex:get_max_lookbehind`_ ()                                 Get the number of characters in the longest lookbehind assertion in the pattern.
`regex:get_capture_count`_ ()                                  Get the number of capturing subpatterns in the pattern.
`regex:get_string_number`_ (name)                              Get the number of the capturing subexpression with the given name.
`regex:get_compile_flags`_ ()                                  Get the names of all compile flags set when regex was created.
`regex:get_match_flags`_ ()                                    Get the names of all matching flags set when regex was created.
`regex:find`_ (s[, start[, mflags]])                           Search for a match in a string.
`regex:tfind`_ (s[, start[, mflags]])                          Search for a match in a string.
`regex:match`_ (s[, start[, mflags]])                          Search for a match in a string.
`regex:gmatch`_ (s[, start[, mflags]])                         Search for all matches in a string.
`regex:gfind`_ (s[, start[, mflags]])                          Search for all matches in a string.
`regex:gtfind`_ (s[, start[, mflags]])                         Search for all matches in a string.
`regex:split`_ (s[, start[, mflags[, max]]])                   Split a string with a regular expression separator.
`regex:gsub`_ (s, repl[, start[, n[, mflags]]])                Replace occurrences of regular expression in string.
============================================================== ================================================================================

`Simple XML Subset Parser`_
---------------------------

============================================================================================ ==============================================================
`markup_escape_text`_ (s)                                                                    Escape text so GMarkup XML parsing will return it to original.
`\_gmarkup_start_element_`_ (ctx, name, attr_names, attr_values)                             The function called when an opening tag of an element is seen.
`\_gmarkup_end_element_`_ (ctx, name[, pop])                                                 The function called when an ending tag of an element is seen.
`\_gmarkup_text_`_ (ctx, text)                                                               The function called when text within an element is seen.
`\_gmarkup_passthrough_`_ (ctx, text)                                                        The function called when unprocessed text is seen.
`\_gmarkup_error_`_ (ctx, text)                                                              The function called when an error occurs during parsing.
`markup_parse_context_new`_ (options)                                                        Create GMarkup parser.
============================================================================================ ==============================================================

Class `markup_parse_context`_
-----------------------------

======================================================================================= =================================================================================
`markup_parse_context:end_parse`_ ()                                                    Finish parsing.
`markup_parse_context:get_position`_ ()                                                 Obtain current position in source text.
`markup_parse_context:get_element`_ ()                                                  Obtain the name of the current element being processed.
`markup_parse_context:get_element_stack`_ ()                                            Obtain the complete path of element names to the current element being processed.
`markup_parse_context:parse`_ (s)                                                       Parse some text.
======================================================================================= =================================================================================

`Key-value file parser`_
------------------------

=================================== =============================
`key_file_new`_ ()                  Create a new, empty key file.
=================================== =============================

Class `key_file`_
-----------------

============================================================================================ ============================================
`key_file:set_list_separator`_ (sep)                                                         Sets character to separate values in lists.
`key_file:load_from_file`_ (f[, dirs[, keep_com[, keep_trans]]])                             Load a file.
`key_file:load_from_data`_ (s[, keep_com[, keep_trans]])                                     Load data.
`key_file:to_data`_ ()                                                                       Convert entire key file to a string.
`key_file:save_to_file`_ (name)                                                              Writes out contents of key file.
`key_file:get_start_group`_ ()                                                               Get the start group of the key file.
`key_file:get_groups`_ ()                                                                    Get the names of all groups in the key file.
`key_file:get_keys`_ (group)                                                                 Get the names of all keys in a group.
`key_file:has_group`_ (group)                                                                Check if group exists.
`key_file:has_key`_ (group, key)                                                             Check if key exists.
`key_file:raw_get`_ (group, key)                                                             Obtain raw value of a key.
`key_file:get`_ (group, key[, locale])                                                       Obtain value of a key.
`key_file:get_boolean`_ (group, key)                                                         Obtain value of a boolean key.
`key_file:get_number`_ (group, key)                                                          Obtain value of a numeric key.
`key_file:get_list`_ (group, key[, locale])                                                  Obtain value of a string list key.
`key_file:get_boolean_list`_ (group, key)                                                    Obtain value of a boolean list key.
`key_file:get_number_list`_ (group, key)                                                     Obtain value of a number list key.
`key_file:get_comment`_ ([group[, key]])                                                     Obtain comment above a key or group.
`key_file:raw_set`_ (group, key, value)                                                      Set raw value of a key.
`key_file:set`_ (group, key, value[, locale])                                                Set value of a key.
`key_file:set_boolean`_ (group, key, value)                                                  Set value of a boolean key.
`key_file:set_number`_ (group, key, value)                                                   Set value of a numeric key.
`key_file:set_list`_ (group, key, value[, locale])                                           Set value of a string list key.
`key_file:set_boolean_list`_ (group, key, value)                                             Set value of a boolean list key.
`key_file:set_number_list`_ (group, key)                                                     Set value of a number list key.
`key_file:set_comment`_ (comment[, group[, key]])                                            Set comment above a key or group.
`key_file:remove`_ (group[, key])                                                            Remove a group or key.
`key_file:remove_comment`_ ([group[, key]])                                                  Remove comment above a key or group.
============================================================================================ ============================================

`Bookmark file parser`_
-----------------------

============================================= ==================================
`bookmark_file_new`_ ()                       Create a new, empty bookmark file.
============================================= ==================================

Class `bookmark_file`_
----------------------

================================================================================================ =============================================================================
`bookmark_file:load_from_file`_ (f[, use_dirs])                                                  Load a file.
`bookmark_file:load_from_data`_ (s)                                                              Load data.
`bookmark_file:to_data`_ ()                                                                      Convert bookmark file to a string.
`bookmark_file:to_file`_ (f)                                                                     Write bookmark file to a file.
`bookmark_file:has_item`_ (uri)                                                                  Check if bookmark file has given URI.
`bookmark_file:has_group`_ (uri, group)                                                          Check if bookmark file has given URI in a given group.
`bookmark_file:has_application`_ (uri, app)                                                      Check if bookmark file has given URI registered by a given application.
`bookmark_file:__len`_ ()                                                                        Get the number of bookmarks.
`bookmark_file:uris`_ ()                                                                         Get all URIs.
`bookmark_file:title`_ (uri)                                                                     Get title for URI
`bookmark_file:description`_ (uri)                                                               Get description for URI
`bookmark_file:mime_type`_ (uri)                                                                 Get MIME type for URI
`bookmark_file:is_private`_ (uri)                                                                Get private flag for URI
`bookmark_file:icon`_ (uri)                                                                      Get icon for URI.
`bookmark_file:added`_ (uri)                                                                     Get time URI was added.
`bookmark_file:modified`_ (uri)                                                                  Get time URI was last modified.
`bookmark_file:visited`_ (uri)                                                                   Get time URI was last visited.
`bookmark_file:groups`_ (uri)                                                                    Get list of groups to which URI belongs.
`bookmark_file:applications`_ (uri)                                                              Get list of applications which registered this URI.
`bookmark_file:boomark_file:app_info`_ (uri, app)                                                Obtain registration information for application which registered URI.
`bookmark_file:set_title`_ ([uri], title)                                                        Set title for URI
`bookmark_file:set_description`_ ([uri], desc)                                                   Set description for URI
`bookmark_file:set_mime_type`_ (uri, mime_type)                                                  Set MIME type for URI
`bookmark_file:set_is_private`_ (uri, private)                                                   Set private flag for URI
`bookmark_file:set_icon`_ (uri, icon, mime_type)                                                 Set icon for URI.
`bookmark_file:set_added`_ (uri, time)                                                           Set time URI was added.
`bookmark_file:set_modified`_ (uri, time)                                                        Set time URI was modified.
`bookmark_file:set_visited`_ (uri, time)                                                         Set time URI was visited.
`bookmark_file:set_groups`_ (uri)                                                                Set list of groups to which URI belongs.
`bookmark_file:set_app_info`_ (uri, app, exec[, rcount[, stamp]])                                Set registration information for application which registered URI.
`bookmark_file:add_group`_ (uri, group)                                                          Add a group to the list of groups URI belongs to.
`bookmark_file:add_application`_ (uri, app, exec)                                                Add an application to the list of applications that registered this URI.
`bookmark_file:remove_group`_ (uri, group)                                                       Remove a group from the list of groups URI belongs to.
`bookmark_file:remove_application`_ (uri, app)                                                   Remove an application from the list of applications that registered this URI.
`bookmark_file:remove`_ (uri)                                                                    Remove URI.
`bookmark_file:move`_ (uri, new)                                                                 Change URI, retaining group and application information.
================================================================================================ =============================================================================

| 

_`Version Information`
----------------------


 .. _`version`:

 **version**
   GLib version string. Version of running glib (not the one it was compiled against). The format is *major*.\ *minor*.\ *micro*.

   .. rubric:: Usage:
      :name: usage

   ::

      gver = tonumber(glib.version:match '(.*)%.')
      print(gver > 2.30)

_`Standard Macros`
------------------


 .. _`os`:

 **os**
   Operating system. A string representing the operating system: ‘win32', ‘beos', ‘unix', ‘unknown'

 .. _`dir_separator`:

 **dir_separator**
   Directory separator. Unlike GLib's directory separator, this includes both valid values under Win32.

 .. _`searchpath_separator`:

 **searchpath_separator**
   Path list separator

_`Message Logging`
------------------


 .. _`log`:

 **log ([domain][, level], msg)**
   Log a message, GLib-style. This is a wrapper for ``g_log()``.

   .. rubric:: Parameters:
      :name: parameters

   -  ``domain``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The log domain. This parameter may be absent to use ``G_LOG_DOMAIN``.

   -  ``level``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The log level. Acceptable values are:

      -  ‘crit'/‘critical'
      -  ‘debug'
      -  ‘err'/‘error'
      -  ‘info'
      -  ‘msg'/‘message'
      -  ‘warn'/‘warning'

      This parameter may be absent along with *domain* to indicate ‘msg'.

   -  ``msg``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The log message. Unlike g_log(), no formatting is permitted. Collect and format your string before logging.

_`Character Set Conversion`
---------------------------


 .. _`\_convert_`:

 **\_convert_ ([str])**
   Stream character conversion function returned by `convert`_             . This function is returned by `convert`_             to support converting streams piecewise. Simply call with string arguments, accumulating the returned strings. When finished with the stream, call with no arguments. This will return the final string to append and reset the stream for reuse.

   .. rubric:: Parameters:
      :name: parameters-1

   -  ``str``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The next piece of the string to convert; absent to finish conversion

   .. rubric:: Usage:
      :name: usage-1

   ::

      c = glib.convert(nil, 'utf-8', 'latin1')
      while true do
        buf = inf:read(4096)
        if not buf then break end
        outf:write(c(buf))
      end
      outf:write(c())

   .. rubric:: Returns:
      :name: returns

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The next piece of the converted string

   .. rubric:: see also:
      :name: see-also

   `convert`_            


 .. _`convert`:

 **convert ([str[, to[, from[, fallback]]]])**
   Convert strings from one character set to another. This is a wrapper for ``g_convert()`` and friends. To convert a stream, pass in no arguments or ``nil`` for str. The return value is either the converted string, or a function matching the `\_convert\_`_               function.

   .. rubric:: Parameters:
      :name: parameters-2

   -  ``str``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to convert, or ``nil``/absent to produce a streaming converter
   -  ``to``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The target character set. This may be ``nil`` or absent to indicate the current locale. This may be ‘filename' to indicate the filename character set.
   -  ``from``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The target character set. This may be ``nil`` or absent to indicate the current locale. This may be ‘filename' to indicate the filename character set.
   -  ``fallback``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Any characters in *from* which have no equivalent in *to* are converted to this string. This is not supported in stream mode.

   .. rubric:: Returns:
      :name: returns-1

   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Converted string, if *str* was specified
   #. **function** stream convert function, if *str* was ``nil`` or missing

   .. rubric:: Raises:
      :name: raises

   Returns ``nil`` and error message string on error.

   .. rubric:: see also:
      :name: see-also-1

   `\_convert\_`_              

_`Unicode Manipulation`
-----------------------


 .. _`validate`:

 **validate (c)**
   Check if unicode character is valid. This is a wrapper for ``g_unichar_validate()``.

   .. rubric:: Parameters:
      :name: parameters-3

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-2

   **boolean** True if *c* is valid

   .. rubric:: Raises:
      :name: raises-1

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`isalpha`:

 **isalpha (c)**
   Check if Unicode character is alphabetic. This is a wrapper for ``g_unichar_isalpha()``.

   .. rubric:: Parameters:
      :name: parameters-4

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-3

   **boolean** True if *c* is alphabetic

   .. rubric:: Raises:
      :name: raises-2

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`iscntrl`:

 **iscntrl (c)**
   Check if Unicode character is a control character. This is a wrapper for ``g_unichar_iscntrl()``.

   .. rubric:: Parameters:
      :name: parameters-5

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-4

   **boolean** True if *c* is a control character

   .. rubric:: Raises:
      :name: raises-3

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`isdefined`:

 **isdefined (c)**
   Check if Unicode character is explicitly defined in the Unicode standard. This is a wrapper for ``g_unichar_isdefined()``.

   .. rubric:: Parameters:
      :name: parameters-6

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-5

   **boolean** True if *c* is defined

   .. rubric:: Raises:
      :name: raises-4

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`isdigit`:

 **isdigit (c)**
   Check if Unicode character is a decimal digit. This is a wrapper for ``g_unichar_isdigit()``.

   .. rubric:: Parameters:
      :name: parameters-7

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-6

   **boolean** True if *c* is a digit-like character

   .. rubric:: Raises:
      :name: raises-5

   Generates argument error if *c* is a string but not valid UTF-8.

   .. rubric:: see also:
      :name: see-also-2

   -  `isxdigit`_             
   -  `digit_value`_                


 .. _`isgraph`:

 **isgraph (c)**
   Check if Unicode character is a visible, printable character. This is a wrapper for ``g_unichar_isgraph()``.

   .. rubric:: Parameters:
      :name: parameters-8

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-7

   **boolean** True if *c* is a graphic character

   .. rubric:: Raises:
      :name: raises-6

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`islower`:

 **islower (c)**
   Check if Unicode character is a lower-case alphabetic character. This is a wrapper for ``g_unichar_islower()``.

   .. rubric:: Parameters:
      :name: parameters-9

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-8

   **boolean** True if *c* is lower-case.

   .. rubric:: Raises:
      :name: raises-7

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`ismark`:

 **ismark (c)**
   Check if Unicode character is a mark. This is a wrapper for ``g_unichar_ismark()``.

   .. rubric:: Parameters:
      :name: parameters-10

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-9

   **boolean** True if *c* is a non-spacing mark, combining mark, or enclosing mark

   .. rubric:: Raises:
      :name: raises-8

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`isprint`:

 **isprint (c)**
   Check if Unicode character is printable. This is a wrapper for ``g_unichar_isprint()``.

   .. rubric:: Parameters:
      :name: parameters-11

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-10

   **boolean** True if *c* is printable, even if blank

   .. rubric:: Raises:
      :name: raises-9

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`ispunct`:

 **ispunct (c)**
   Check if Unicode character is a punctuation or symbol character. This is a wrapper for ``g_unichar_ispunct()``.

   .. rubric:: Parameters:
      :name: parameters-12

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-11

   **boolean** True if *c* is a punctuation or symbol character

   .. rubric:: Raises:
      :name: raises-10

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`isspace`:

 **isspace (c)**
   Check if Unicode character is whitespace. This is a wrapper for ``g_unichar_isspace()``.

   .. rubric:: Parameters:
      :name: parameters-13

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-12

   **boolean** True if *c* is whitespace

   .. rubric:: Raises:
      :name: raises-11

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`istitle`:

 **istitle (c)**
   Check if Unicode character is titlecase. This is a wrapper for ``g_unichar_istitle()``.

   .. rubric:: Parameters:
      :name: parameters-14

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-13

   **boolean** True if *c* is titlecase alphabetic

   .. rubric:: Raises:
      :name: raises-12

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`isupper`:

 **isupper (c)**
   Check if Unicode character is upper-case. This is a wrapper for ``g_unichar_isupper()``.

   .. rubric:: Parameters:
      :name: parameters-15

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-14

   **boolean** True if *c* is upper-case alphabetic

   .. rubric:: Raises:
      :name: raises-13

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`isxdigit`:

 **isxdigit (c)**
   Check if Unicode character is hexadecimal digit. This is a wrapper for ``g_unichar_isxdigit()``.

   .. rubric:: Parameters:
      :name: parameters-16

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-15

   **boolean** True if *c* is a hexadecimal digit

   .. rubric:: Raises:
      :name: raises-14

   Generates argument error if *c* is a string but not valid UTF-8.

   .. rubric:: see also:
      :name: see-also-3

   -  `isdigit`_            
   -  `xdigit_value`_                 


 .. _`iswide`:

 **iswide (c)**
   Check if Unicode character is wide. This is a wrapper for ``g_unichar_iswide()``.

   .. rubric:: Parameters:
      :name: parameters-17

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-16

   **boolean** True if *c* is double-width

   .. rubric:: Raises:
      :name: raises-15

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`iswide_cjk`:

 **iswide_cjk (c)**
   Check if Unicode character is wide in legacy East Asian locales. This is a wrapper for ``g_unichar_iswide_cjk()``.

   .. rubric:: Parameters:
      :name: parameters-18

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-17

   **boolean** True if *c* is double-width normally or in legacy East-Asian locales

   .. rubric:: Raises:
      :name: raises-16

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`iszerowidth`:

 **iszerowidth (c)**
   Check if Unicode character is zero-width. This is a wrapper for ``g_unichar_iszerowidth()``.

   .. rubric:: Parameters:
      :name: parameters-19

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-18

   **boolean** True if *c* is a zero-width combining character

   .. rubric:: Raises:
      :name: raises-17

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`toupper`:

 **toupper (c)**
   Convert Unicode character to upper-case. This is a wrapper for ``g_unichar_toupper()``.

   .. rubric:: Parameters:
      :name: parameters-20

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-19

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The result of conversion, as either an integer or a utf-8 string, depending on what *c* was.

   .. rubric:: Raises:
      :name: raises-18

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`tolower`:

 **tolower (c)**
   Convert Unicode character to lower-case. This is a wrapper for ``g_unichar_tolower()``.

   .. rubric:: Parameters:
      :name: parameters-21

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-20

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The result of conversion, as either an integer or a utf-8 string, depending on what *c* was.

   .. rubric:: Raises:
      :name: raises-19

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`totitle`:

 **totitle (c)**
   Convert Unicode character to title case. This is a wrapper for ``g_unichar_totitle()``.

   .. rubric:: Parameters:
      :name: parameters-22

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-21

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The result of conversion, as either an integer or a utf-8 string, depending on what *c* was.

   .. rubric:: Raises:
      :name: raises-20

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`digit_value`:

 **digit_value (c)**
   Convert digit to its numeric value. This is a wrapper for ``g_unichar_digit_value()``.

   .. rubric:: Parameters:
      :name: parameters-23

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-22

   **number** The digit's numeric value

   .. rubric:: Raises:
      :name: raises-21

   Generates argument error if *c* is a string but not valid UTF-8. Returns -1 if *c* is not a digit.

   .. rubric:: see also:
      :name: see-also-4

   `isdigit`_            


 .. _`xdigit_value`:

 **xdigit_value (c)**
   Convert hexadecimal digit to its numeric value. This is a wrapper for ``g_unichar_xdigit_value()``.

   .. rubric:: Parameters:
      :name: parameters-24

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-23

   **number** The hex digit's numeric value

   .. rubric:: Raises:
      :name: raises-22

   Generates argument error if *c* is a string but not valid UTF-8. Returns -1 if *c* is not a hex digit.

   .. rubric:: see also:
      :name: see-also-5

   `isxdigit`_             


 .. _`type`:

 **type (c)**
   Find Unicode character class. This is a wrapper for ``g_unichar_type()``.

   .. rubric:: Parameters:
      :name: parameters-25

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-24

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The character's class; one of: ``control``, ``format``, ``unassigned``, ``private_use``, ``surrogate``, ``lowercase_letter``, ``modifier_letter``, ``other_letter``, ``titlecase_letter``, ``uppercase_letter``, ``spacing_mark``, ``enclosing_mark``, ``non_spacing_mark``, ``decimal_number``, ``letter_number``, ``other_number``, ``connect_punctuation``, ``dash_punctuation``, ``close_punctuation``, ``final_punctuation``,
   ``initial_punctuation``, ``other_punctuation``, ``open_punctuation``, ``currency_symbol``, ``modifier_symbol``, ``math_symbol``, ``other_symbol``, ``line_separator``, ``paragraph_separator``, ``space_separator``.

   .. rubric:: Raises:
      :name: raises-23

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`break_type`:

 **break_type (c)**
   Find Unicode character's line break classification. This is a wrapper for ``g_unichar_break_type()``.

   .. rubric:: Parameters:
      :name: parameters-26

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-25

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The line break classification; one of: ``mandatory``, ``carriage_return``, ``line_feed``, ``combining_mark``, ``surrogate``, ``zero_width_space``, ``inseperable``, ``non_breaking_glue``, ``contingent``, ``space``, ``after``, ``before``, ``before_and_after``, ``hyphen``, ``non_starter``, ``open_punctuation``, ``close_punctuation``, ``quotation``, ``exclamation``, ``ideographic``, ``numeric``, ``infix_separator``, ``symbol``,
   ``alphabetic``, ``prefix``, ``postfix``, ``complex_context``, ``ambiguous``, ``unknown``, ``next_line``, ``word_joiner``, ``hangul_l_jamo``, ``hangul_v_jamo``, ``hangul_t_jamo``, ``hangul_lv_syllable``, ``hangul_lvt_syllable``, ``close_parenthesis``, ``conditional_japanese_starter``, ``hebrew_letter``.

   .. rubric:: Raises:
      :name: raises-24

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`get_mirror_char`:

 **get_mirror_char (c)**
   Find Unicode mirroring character. This is a wrapper for ``g_unichar_get_mirror_char()``.

   .. rubric:: Parameters:
      :name: parameters-27

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-26

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** \|\ **nil** ``nil`` if the character has no mirror; otherwise, the mirror character. The returned character is either an integer or a utf-8 string, depending on the input.

   .. rubric:: Raises:
      :name: raises-25

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`get_script`:

 **get_script (c)**
   Find ISO 15924 script for a Unicode character. This is a wrapper for ``g_unichar_get_script()``.

   This is only available with GLib 2.30 or later.

   .. rubric:: Parameters:
      :name: parameters-28

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-27

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The four-letter ISO 15924 script code for *c*.

   .. rubric:: Raises:
      :name: raises-26

   Generates argument error if *c* is a string but not valid UTF-8.


 .. _`utf8_sub`:

 **utf8_sub (s[, first[, last]])**
   Obtain a substring of a utf-8-encoded string. This is not a wrapper for ``g_utf8_substring()``, but instead code which emulates `string.sub <http://www.lua.org/manual/5.1/manual.html#pdf-string.sub>`__ using ``g_utf8_offset_to_pointer()`` and ``g_utf8_strlen()``. Positive positions start at the beginining of the string, and negative positions start at the end. Position numbers refer to code points rather than byte offsets.

   .. rubric:: Parameters:
      :name: parameters-29

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The utf-8-encoded source string
   -  ``first``: **number** The first Unicode code point (default is 1)
   -  ``last``: **number** The last Unicode code point (default is -1)

   .. rubric:: Returns:
      :name: returns-28

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The requested substring. Out-of-bound ranges result in an empty string.


 .. _`utf8_len`:

 **utf8_len (s)**
   Obtain the number of code points in a utf-8-encoded string. This is a wrapper for ``g_utf8_strlen()``.

   .. rubric:: Parameters:
      :name: parameters-30

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string

   .. rubric:: Returns:
      :name: returns-29

   **number** The length of *s*, in code points.


 .. _`utf8_validate`:

 **utf8_validate (s)**
   Check if a string is valid UTF-8. This is a wrapper for ``g_utf8_validate()``.

   .. rubric:: Parameters:
      :name: parameters-31

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string

   .. rubric:: Returns:
      :name: returns-30

   **boolean** True if *s* is valid UTF-8.


 .. _`utf8_strup`:

 **utf8_strup (s)**
   Convert UTF-8 string to upper-case. This is a wrapper for ``g_utf8_strup()``.

   .. rubric:: Parameters:
      :name: parameters-32

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The source string

   .. rubric:: Returns:
      :name: returns-31

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ *s*, with all lower-case characters converted to upper-case


 .. _`utf8_strdown`:

 **utf8_strdown (s)**
   Convert UTF-8 string to lower-case. This is a wrapper for ``g_utf8_strdown()``.

   .. rubric:: Parameters:
      :name: parameters-33

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The source string

   .. rubric:: Returns:
      :name: returns-32

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ *s*, with all upper-case characters converted to lower-case


 .. _`utf8_casefold`:

 **utf8_casefold (s)**
   Convert UTF-8 string to case-independent form. This is a wrapper for ``g_utf8_casefold()``.

   .. rubric:: Parameters:
      :name: parameters-34

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The source string

   .. rubric:: Returns:
      :name: returns-33

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ *s*, in a form that is suitable for case-insensitive direct string comparison.


 .. _`utf8_normalize`:

 **utf8_normalize (s[, compose[, compatible]])**
   Perform standard Unicode normalization on a UTF-8 string. This is a wrapper for ``g_utf8_normalize()``. The four standard normalizations are NFD (the default), NFC (compose), NFKD (compatible), and NFKC (compose, compatible).

   .. rubric:: Parameters:
      :name: parameters-35

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to normalize
   -  ``compose``: **boolean** If true, perform canonical composition. Otherwise, leave in decomposed form.
   -  ``compatible``: **boolean** If true, decompose using compatibility decompostions. Otherwise, only decompose using canonical decompositions.

   .. rubric:: Returns:
      :name: returns-34

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The normalized UTF-8 string.


 .. _`utf8_collate`:

 **utf8_collate (s1, s2)**
   Compare UTF-8 strings for collation. This is a wrapper for ``g_utf8_collate()``.

   .. rubric:: Parameters:
      :name: parameters-36

   -  ``s1``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The first string
   -  ``s2``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The second string

   .. rubric:: Returns:
      :name: returns-35

   **number** Numeric comparison result: less than zero if *s1* comes before *s2*, greater than zero if *s1* comes after *s2*, and zero if *s1* and *s2* are equivalent.

   .. rubric:: see also:
      :name: see-also-6

   -  `utf8_collate_key`_                     
   -  `utf8_collate_key_for_filename`_                                  


 .. _`utf8_collate_key`:

 **utf8_collate_key (s)**
   Create a comparison key for a UTF-8 string. This is a wrapper for ``g_utf8_collate_key()``.

   .. rubric:: Parameters:
      :name: parameters-37

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string.

   .. rubric:: Returns:
      :name: returns-36

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ A form of the string which can be compared using direct string comparison rather than utf8_collate.

   .. rubric:: see also:
      :name: see-also-7

   -  `utf8_collate`_                 
   -  `utf8_collate_key_for_filename`_                                  


 .. _`utf8_collate_key_for_filename`:

 **utf8_collate_key_for_filename (s)**
   Create a comparison key for a UTF-8 filename string. This is a wrapper for ``g_collate_key_for_filename()``.

   .. rubric:: Parameters:
      :name: parameters-38

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string.

   .. rubric:: Returns:
      :name: returns-37

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ A form of the string which can be compared using direct string comparison. Dots and numeric sequences are treated differently. There is no equivalent ``utf8_collate_filename()``.

   .. rubric:: see also:
      :name: see-also-8

   -  `utf8_collate`_                 
   -  `utf8_collate_key`_                     


 .. _`utf8_to_utf16`:

 **utf8_to_utf16 (s)**
   Convert a UTF-8 string to UTF-16. This is a wrapper for ``g_utf8_to_utf16()``.

   .. rubric:: Parameters:
      :name: parameters-39

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The source string

   .. rubric:: Returns:
      :name: returns-38

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ *s*, converted to UTF-16

   .. rubric:: Raises:
      :name: raises-27

   Returns ``nil`` followed by an error message if *s* is not valid UTF-8.


 .. _`utf8_to_ucs4`:

 **utf8_to_ucs4 (s)**
   Convert a UTF-8 string to UCS-4. This is a wrapper for ``g_utf8_to_ucs4()``.

   .. rubric:: Parameters:
      :name: parameters-40

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The source string

   .. rubric:: Returns:
      :name: returns-39

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ *s*, converted to UCS-4

   .. rubric:: Raises:
      :name: raises-28

   Returns ``nil`` followed by an error message if *s* is not valid UTF-8.


 .. _`utf16_to_utf8`:

 **utf16_to_utf8 (s)**
   Convert a UTF-16 string to UTF-8. This is a wrapper for ``g_utf16_to_utf8()``.

   .. rubric:: Parameters:
      :name: parameters-41

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The source string

   .. rubric:: Returns:
      :name: returns-40

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ *s*, converted to UTF-8

   .. rubric:: Raises:
      :name: raises-29

   Returns ``nil`` followed by an error message if *s* is not valid UTF-16.


 .. _`utf16_to_ucs4`:

 **utf16_to_ucs4 (s)**
   Convert a UTF-16 string to UCS-4. This is a wrapper for ``g_utf16_to_ucs4()``.

   .. rubric:: Parameters:
      :name: parameters-42

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The source string

   .. rubric:: Returns:
      :name: returns-41

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ *s*, converted to UCS-4

   .. rubric:: Raises:
      :name: raises-30

   Returns ``nil`` followed by an error message if *s* is not valid UTF-16.


 .. _`ucs4_to_utf16`:

 **ucs4_to_utf16 (s)**
   Convert a UCS-4 string to UTF-16. This is a wrapper for ``g_utf8_to_utf16()``.

   .. rubric:: Parameters:
      :name: parameters-43

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The source string

   .. rubric:: Returns:
      :name: returns-42

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ *s*, converted to UTF-16

   .. rubric:: Raises:
      :name: raises-31

   Returns ``nil`` followed by an error message if *s* is not valid UCS-4.


 .. _`ucs4_to_utf8`:

 **ucs4_to_utf8 (s)**
   Convert a UCS-4 string to UTF-8. This is a wrapper for ``g_utf16_to_utf8()``.

   .. rubric:: Parameters:
      :name: parameters-44

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The source string

   .. rubric:: Returns:
      :name: returns-43

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ *s*, converted to UTF-8

   .. rubric:: Raises:
      :name: raises-32

   Returns ``nil`` followed by an error message if *s* is not valid UCS-4.


 .. _`to_utf8`:

 **to_utf8 (c)**
   Convert a UCS-4 code point to UTF-8. This is a wrapper for ``g_unichar_to_utf8()``.

   .. rubric:: Parameters:
      :name: parameters-45

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The Unicode character, as either an integer or a utf-8 string.

   .. rubric:: Returns:
      :name: returns-44

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ A UTF-8 string representing *c*. Note that this basically has no effect if *c* is a single-character string already.

   .. rubric:: Raises:
      :name: raises-33

   Generates argument error if *c* is a string but not valid UTF-8.

_`Base64 Encoding`
------------------


 .. _`\_base64_encode_`:

 **\_base64_encode_ ([s])**
   Stream Base64-encoding function returned by `base64_encode`_                   . This function is returned by `base64_encode`_                   to support piecewise-encoding streams. Simply call with string arguments, accumulating the returned strings. When finished with the stream, call with no arguments. This will return the final string to append and reset the stream for reuse.

   .. rubric:: Parameters:
      :name: parameters-46

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The next piece of the string to convert; absent to finish conversion

   .. rubric:: Usage:
      :name: usage-2

   ::

      enc = glib.base64_encode()
      while true do
        buf = inf:read(4096)
        if not buf then break end
        outf:write(enc(buf))
      end
      outf:write(enc())

   .. rubric:: Returns:
      :name: returns-45

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The next piece of the converted string

   .. rubric:: see also:
      :name: see-also-9

   `base64_encode`_                  


 .. _`base64_encode`:

 **base64_encode ([s])**
   Base64-encode a string. This is a wrapper for ``g_base64_encode()`` and friends.

   .. rubric:: Parameters:
      :name: parameters-47

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The data to encode. If absent, return a function like `\_base64_encode\_`_                     for encoding a stream.

   .. rubric:: Returns:
      :name: returns-46

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **function** The base64-encoded stream (without newlines), or a function to do the same on a stream.

   .. rubric:: see also:
      :name: see-also-10

   `\_base64_encode\_`_                    


 .. _`\_base64_decode_`:

 **\_base64_decode_ ([s])**
   Stream Base64-decoding function returned by `base64_decode`_                   . This function is returned by `base64_decode`_                   to support piecewise-decoding streams. Simply call with string arguments, accumulating the returned strings. When finished with the stream, call with no arguments. This will return the final string to append and reset the stream for reuse.

   .. rubric:: Parameters:
      :name: parameters-48

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The next piece of the string to convert; absent to finish conversion

   .. rubric:: Usage:
      :name: usage-3

   ::

      dec = glib.base64_decode()
      while true do
        buf = inf:read(4096)
        if not buf then break end
        outf:write(dec(buf))
      end
      outf:write(dec())

   .. rubric:: Returns:
      :name: returns-47

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The next piece of the converted output

   .. rubric:: see also:
      :name: see-also-11

   `base64_decode`_                  


 .. _`base64_decode`:

 **base64_decode ([s])**
   Base64-decode a string. This is a wrapper for ``g_base64_deocde()`` and friends.

   .. rubric:: Parameters:
      :name: parameters-49

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The data to decode. If absent, return a function like *base64_decode* for decoding a stream.

   .. rubric:: Returns:
      :name: returns-48

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **function** The decoded form of the base64-encoded stream, or a function to do the same on a stream.

   .. rubric:: see also:
      :name: see-also-12

   `\_base64_decode\_`_                    

_`Data Checksums`
-----------------


 .. _`\_sum_`:

 **\_sum_ ([s][, raw])**
   Stream checksum/hash calculation function type. This function is returned by `md5sum`_            , `sha1sum`_             , or `sha256sum`_               to support computing stream checksums piecewise. Simply call with string arguments, until the stream is complete. Then, call with an absent or ``nil`` argument to return the final checksum. Doing so invalidates the state, so that the function returns an error from that point forward.

   .. rubric:: Parameters:
      :name: parameters-50

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The next piece of the string to checksum; absent or ``nil`` to finish checksum
   -  ``raw``: **boolean** True if checksum should be returned in binary form. Otherwise, return the lower-case hexadecimal-encoded form (ignored if *s* is not ``nil``)

   .. rubric:: Usage:
      :name: usage-4

   ::

      sumf = glib.md5sum()
      while true do
        buf = inf:read(4096)
        if not buf then break end
        sumf(buf)
      end
      sum = sumf()

   .. rubric:: Returns:
      :name: returns-49

   \|\ **nil** \|\ `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Nothing unless *s* is absent or ``nil``. Otherwise, return the computed checksum.

   .. rubric:: Raises:
      :name: raises-34

   If the state is invalid, always return ``nil``.

   .. rubric:: see also:
      :name: see-also-13

   -  `md5sum`_           
   -  `sha1sum`_            
   -  `sha256sum`_              


 .. _`md5sum`:

 **md5sum ([s[, raw]])**
   Compute MD5 checksum of a string. This is a wrapper for ``g_checksum_new()`` and friends.

   .. rubric:: Parameters:
      :name: parameters-51

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The data to checksum. If absent, return a function like `\_sum\_`_           to checksum a stream piecewise.
   -  ``raw``: **boolean** True if checksum should be returned in binary form. Otherwise, return the lower-case hexadecimal-encoded form (ignored if *s* is ``nil``)

   .. rubric:: Returns:
      :name: returns-50

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **function** The MD5 checksum or a stream converter function.

   .. rubric:: see also:
      :name: see-also-14

   `\_sum\_`_          


 .. _`sha1sum`:

 **sha1sum ([s[, raw]])**
   Compute SHA1 checksum of a string. This is a wrapper for ``g_checksum_new()`` and friends.

   .. rubric:: Parameters:
      :name: parameters-52

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The data to checksum. If absent, return a function like `\_sum\_`_           to checksum a stream piecewise.
   -  ``raw``: **boolean** True if checksum should be returned in binary form. Otherwise, return the lower-case hexadecimal-encoded form (ignored if *s* is ``nil``)

   .. rubric:: Returns:
      :name: returns-51

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **function** The SHA1 checksum or a stream converter function.

   .. rubric:: see also:
      :name: see-also-15

   `\_sum\_`_          


 .. _`sha256sum`:

 **sha256sum ([s[, raw]])**
   Compute SHA256 checksum of a string. This is a wrapper for ``g_checksum_new()`` and friends.

   .. rubric:: Parameters:
      :name: parameters-53

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The data to checksum. If absent, return a function like `\_sum\_`_           to checksum a stream piecewise.
   -  ``raw``: **boolean** True if checksum should be returned in binary form. Otherwise, return the lower-case hexadecimal-encoded form (ignored if *s* is ``nil``)

   .. rubric:: Returns:
      :name: returns-52

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **function** The SHA256 checksum or a stream converter function.

   .. rubric:: see also:
      :name: see-also-16

   `\_sum\_`_          

_`Secure HMAC Digests`
----------------------


 .. _`\_hmac_`:

 **\_hmac_ ([s][, raw])**
   Stream HMAC calculation function. This function is returned by `md5hmac`_             , `sha1hmac`_              , or `sha256hmac`_                to support computing stream digests piecewise. Simply call with string arguments, until the stream is complete. Then, call with an absent or ``nil`` argument to return the final digest. Doing so invalidates the state, so that the function returns an error from that point forward.

   .. rubric:: Parameters:
      :name: parameters-54

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The next piece of the string to digest; absent or ``nil`` to finish digest
   -  ``raw``: **boolean** True if digest should be returned in binary form. Otherwise, return the lower-case hexadecimal-encoded form (ignored if *s* is not ``nil``)

   .. rubric:: Usage:
      :name: usage-5

   ::

      hmacf = glib.md5hmac(key)
      while true do
        buf = inf:read(4096)
        if not buf then break end
        hmacf(buf)
      end
      hmac = hmacf()

   .. rubric:: Returns:
      :name: returns-53

   \|\ **nil** \|\ `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Nothing unless *s* is absent or ``nil``. Otherwise, return the computed digest.

   .. rubric:: Raises:
      :name: raises-35

   If the state is invalid, always return ``nil``.

   .. rubric:: see also:
      :name: see-also-17

   -  `md5hmac`_            
   -  `sha1hmac`_             
   -  `sha256hmac`_               


 .. _`md5hmac`:

 **md5hmac (key[, s[, raw]])**
   Compute secure HMAC digest using MD5. This is a wrapper for ``g_hmac_new()`` and friends.

   This is only available with GLib 2.30 or later.

   .. rubric:: Parameters:
      :name: parameters-55

   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ HMAC key
   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The data to digest. If absent, return a function like `\_hmac\_`_            to digest a stream piecewise.
   -  ``raw``: **boolean** True if digest should be returned in binary form. Otherwise, return the lower-case hexadecimal-encoded form (ignored if *s* is ``nil``)

   .. rubric:: Returns:
      :name: returns-54

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **function** The MD5 HMAC digest or a stream converter function.

   .. rubric:: see also:
      :name: see-also-18

   `\_hmac\_`_           


 .. _`sha1hmac`:

 **sha1hmac (key[, s[, raw]])**
   Compute secure HMAC digest using SHA1. This is a wrapper for ``g_hmac_new()`` and friends.

   This is only available with GLib 2.30 or later.

   .. rubric:: Parameters:
      :name: parameters-56

   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ HMAC key
   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The data to digest. If absent, return a function like `\_hmac\_`_            to digest a stream piecewise.
   -  ``raw``: **boolean** True if digest should be returned in binary form. Otherwise, return the lower-case hexadecimal-encoded form (ignored if *s* is ``nil``)

   .. rubric:: Returns:
      :name: returns-55

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **function** The SHA1 HMAC digest or a stream converter function.

   .. rubric:: see also:
      :name: see-also-19

   `\_hmac\_`_           


 .. _`sha256hmac`:

 **sha256hmac (key[, s[, raw]])**
   Compute secure HMAC digest using SHA256. This is a wrapper for ``g_hmac_new()`` and friends.

   This is only available with GLib 2.30 or later.

   .. rubric:: Parameters:
      :name: parameters-57

   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ HMAC key
   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The data to digest. If absent, return a function like `\_hmac\_`_            to digest a stream piecewise.
   -  ``raw``: **boolean** True if digest should be returned in binary form. Otherwise, return the lower-case hexadecimal-encoded form (ignored if *s* is ``nil``)

   .. rubric:: Returns:
      :name: returns-56

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **function** The SHA256 HMAC digest or a stream converter function.

   .. rubric:: see also:
      :name: see-also-20

   `\_hmac\_`_           

_`Internationalization`
-----------------------

Note that in general, you will need to use `os.setlocale <http://www.lua.org/manual/5.1/manual.html#pdf-os.setlocale>`__ and `textdomain`_                to initialize this. For example, for the application myapp, with locale files under the current directory:

::

   os.setlocale("")
   glib.textdomain("myapp", glib.get_current_dir())

To extract messages from Lua files using these functions, the following command can be used (may require recent gettext to support -k:g and lua):

::

   xgettext -L lua -kQ_:1g -kC_:1c,2 -kNC_:1c,2 -kN_ -kglib.ngettext:1,2 \
            -ofile.po file.lua

to produce ``file.po`` from ``file.lua``.


 .. _`textdomain`:

 **textdomain ([domain[, path[, encoding]]])**
   Set or query text message database location. Before this function is called, a default message database is used. This sets or queries the domain (also known as package or application) name, and optionally sets or queries the domain's physical file system location. It may also be used to set the encoding of output messages if not the default for the locale. Note that none of the exported translation functions take a domain name parameter, so this function may need to be called before every
   translation from a different domain.

   .. rubric:: Parameters:
      :name: parameters-58

   -  ``domain``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **nil** The domain to use for subsequent translation calls. If ``nil`` or missing, no change is made.
   -  ``path``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **nil** The path to message files, if not the system default. If ``nil`` or missing, no change is made.
   -  ``encoding``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **nil** The encoding of translation output. If ``nil`` or missing, no change is made.

   .. rubric:: Returns:
      :name: returns-57

   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The current (new if set) domain for future translations.
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The path to the translation strings for the current domain.
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The encoding used for output messages. If ``nil``, the locale's default is used.


 .. _`\_`:

 **\_ (s)**
   Replace text with its translation. This is a wrapper for ``_()``. It resides in the global symbol table rather than in `glib`_      .

   .. rubric:: Parameters:
      :name: parameters-59

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The text to translate

   .. rubric:: Returns:
      :name: returns-58

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The translated text, or *s* if there is no translation


 .. _`Q_`:

 **Q_ (s)**
   Replace text and context with its translation. This is a wrapper for ``Q_()``. It resides in the global symbol table rather than in `glib`_      .

   .. rubric:: Parameters:
      :name: parameters-60

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ the optional context, followed by a vertical bar, followed by the text to translate

   .. rubric:: Returns:
      :name: returns-59

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The translated text, or *s* with its context stripped if there is no translation


 .. _`C_`:

 **C_ (c, s)**
   Replace text and context with its translation. This is a wrapper for ``C_()``. It resides in the global symbol table rather than in `glib`_      .

   .. rubric:: Parameters:
      :name: parameters-61

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The context
   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The text to translate

   .. rubric:: Returns:
      :name: returns-60

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The translated text, or *s* if there is no translation


 .. _`N_`:

 **N_ (s)**
   Mark text for translation. This is a wrapper for ``N_()``. It resides in the global symbol table rather than in `glib`_      .

   .. rubric:: Parameters:
      :name: parameters-62

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The text to translate

   .. rubric:: Returns:
      :name: returns-61

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ *s*


 .. _`NC_`:

 **NC_ (c, s)**
   Mark text for translation with context. This is a wrapper for ``NC_()``. It resides in the global symbol table rather than in `glib`_      .

   .. rubric:: Parameters:
      :name: parameters-63

   -  ``c``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The context
   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The text to translate.

   .. rubric:: Returns:
      :name: returns-62

   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ *s*
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ *c*


 .. _`ngettext`:

 **ngettext (singular, plural, n)**
   Replace text with its number-appropriate translation. This is a wrapper for ``g_dngettext()``.

   .. rubric:: Parameters:
      :name: parameters-64

   -  ``singular``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The text to translate if *n* is 1
   -  ``plural``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The text to translate if *n* is not 1
   -  ``n``: **number** The number of items being translated

   .. rubric:: Returns:
      :name: returns-63

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The translated text, or *singular* if there is no translation and *n* is 1, or *plural* if there is no translation and *n* is not 1.


 .. _`get_locale_variants`:

 **get_locale_variants ([locale])**
   Obtain list of valid locale names. This is a wrapper for ``g_get_locale_variants()`` and ``g_get_language_names()``.

   This is only available with GLib 2.28 or later.

   .. rubric:: Parameters:
      :name: parameters-65

   -  ``locale``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ If present, find valid locale names derived from this. Otherwise, find valid names for the default locale (including C).

   .. rubric:: Returns:
      :name: returns-64

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}A table array containing valid names for the locale, in order of preference.

_`Date and Time Functions`
--------------------------


 .. _`sleep`:

 **sleep (t)**
   Suspend execution for some seconds. This is a wrapper for ``g_usleep()``.

   .. rubric:: Parameters:
      :name: parameters-66

   -  ``t``: **number** Number of seconds to sleep (microsecond accuracy)


 .. _`usleep`:

 **usleep (t)**
   Suspend execution for some microseconds. This is a wrapper for ``g_usleep()``.

   .. rubric:: Parameters:
      :name: parameters-67

   -  ``t``: **number** Number of microseconds to sleep

_`Random Numbers`
-----------------

Note that no high-level wrapper functions are provided similar to those in cmorris' glib wrapper. Instead, pure Lua functions should be used:

::

   function shuffle(a)
       local i
       for i = 1, #a do
           local r = glib.random(#a)
           local t = a[i]
           a[i] = a[r]
           a[r] = t
       end
   end

   function choice(a)
       if #a == 0 then
           return nil
       end
       return a[glib.random(#a)];
   end

   function sample(a, n)
       local b = {}
       local s = {}
       local i
       for i = 1, n do
           -- warning, this could take a while if n is near #a
           repeat
               r = glib.random(#a)
               -- to force this to run in predictable time, do this:
               -- while not b[r] do r = r % #a + 1 end
           until not b[r]
           b[r] = true
           s[i] = a[r]
       end
       return s
   end

..


 .. _`random`:

 **random ([low[, high]])**
   Obtain a psuedorandom number. This is a wrapper for ``g_random()`` and friends. This is a clone of the standard Lua `math.random <http://www.lua.org/manual/5.1/manual.html#pdf-math.random>`__ , but using a different random number algorithm. Note that there is no way to set the seed; use `rand_new`_              if you need to do that. In fact, you can simply replace `random`_            with the results of `rand_new`_              if you want to simulate setting a seed for this function.

   .. rubric:: Parameters:
      :name: parameters-68

   -  ``low``: **number** If *high* is present, this is the low end of the range of random integers to return
   -  ``high``: **number** If present, return a range of random integers, from *low* to *high* inclusive. If not present, return a floating point number in the range from zero to one exclusive of one. If *low* is not present, and *high* is, *low* is 1.

   .. rubric:: Usage:
      :name: usage-6

   ::

      -- set a seed for glib.random
      glib.random = glib.rand_new(seed)

   .. rubric:: see also:
      :name: see-also-21

   -  `rand_new`_             
   -  `math.random <http://www.lua.org/manual/5.1/manual.html#pdf-math.random>`__


 .. _`rand_new`:

 **rand_new ([seed])**
   Obtain a psuedorandom number generator, given a seed. This is a wrapper for ``g_rand_new()`` and friends.

   .. rubric:: Parameters:
      :name: parameters-69

   -  ``seed``: **number** \|{**number** ,...} seed (if not specified, one will be selected by the library). This may be either a number or a table array of numbers.

   .. rubric:: Returns:
      :name: returns-65

   **function** A function with the same behavior as `random`_            .

   .. rubric:: see also:
      :name: see-also-22

   `random`_           

_`Miscellaneous Utility Functions`
----------------------------------


 .. _`application_name`:

 **application_name ([name])**
   Set or get localized application name. This is a wrapper for ``g_get_application_name()`` and friends.

   .. rubric:: Parameters:
      :name: parameters-70

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ If present, set the application name

   .. rubric:: Returns:
      :name: returns-66

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name of the application, as set by a previous invocation of this function.

   .. rubric:: see also:
      :name: see-also-23

   `prgname`_            


 .. _`prgname`:

 **prgname ([name])**
   Set or get program name. This is a wrapper for ``g_get_prgname()`` and friends.

   .. rubric:: Parameters:
      :name: parameters-71

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ If present, set the program name

   .. rubric:: Returns:
      :name: returns-67

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name of the program, as set by a previous invocation of this function.

   .. rubric:: see also:
      :name: see-also-24

   `application_name`_                     


 .. _`getenv`:

 **getenv (name)**
   Get environment variable value. This is a wrapper for ``g_getenv()``. It is safer to use this than `os.getenv <http://www.lua.org/manual/5.1/manual.html#pdf-os.getenv>`__ if you are going to modify the environment.

   .. rubric:: Parameters:
      :name: parameters-72

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Name of environment variable to retrieve

   .. rubric:: Returns:
      :name: returns-68

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Value of variable (string) if present; otherwise nil

   .. rubric:: see also:
      :name: see-also-25

   -  `setenv`_           
   -  `unsetenv`_             


 .. _`setenv`:

 **setenv (name, value[, replace])**
   Set environment variable value. This is a wrapper for ``g_setenv()``. If you use this, you should use glib.`getenv`_            instead of `os.getenv <http://www.lua.org/manual/5.1/manual.html#pdf-os.getenv>`__ as well.

   .. rubric:: Parameters:
      :name: parameters-73

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Name of variable to set
   -  ``value``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ New value of variable
   -  ``replace``: **boolean** True to replace if exists; otherwise leave old value

   .. rubric:: Returns:
      :name: returns-69

   **boolean** True if set succeeded; false otherwise

   .. rubric:: see also:
      :name: see-also-26

   -  `getenv`_           
   -  `unsetenv`_             


 .. _`unsetenv`:

 **unsetenv (name)**
   Remove environment variable. This is a wrapper for ``g_unsetenv()``. If you use this, you should use glib.`getenv`_            instead of `os.getenv <http://www.lua.org/manual/5.1/manual.html#pdf-os.getenv>`__ as well.

   .. rubric:: Parameters:
      :name: parameters-74

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Name of variable to remove from environment

   .. rubric:: see also:
      :name: see-also-27

   -  `getenv`_           
   -  `setenv`_           


 .. _`listenv`:

 **listenv ()**
   Obtain names of all environment variables. This is a wrapper for ``g_listenv()``.

   .. rubric:: Returns:
      :name: returns-70

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}An array table whose entries are environment variable names


 .. _`get_user_name`:

 **get_user_name ()**
   Obtain system user name for current user. This is a wrapper for ``g_get_user_name()``.

   .. rubric:: Returns:
      :name: returns-71

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name of the user


 .. _`get_real_name`:

 **get_real_name ()**
   Obtain full user name for current user. This is a wrapper for ``g_get_real_name()``.

   .. rubric:: Returns:
      :name: returns-72

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The full name of the user, or Unknown if this cannot be obtained.


 .. _`get_dir_name`:

 **get_dir_name (d)**
   Obtain a standard directory name. This is a wrapper for ``g_get_*_dir()``.

   .. rubric:: Parameters:
      :name: parameters-75

   -  ``d``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The directory to obtain; one of ``cache``, ``config``, ``data``, ``desktop``, ``documents``, ``download``, ``home``, ``music``, ``pictures``, ``runtime``, ``share``, ``system_config``, ``system_data``, ``templates``, ``tmp``, ``videos``, ``list``. ``list`` just returns this list of names.

   .. rubric:: Returns:
      :name: returns-73

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|{`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}The directory (a string) if there can be only one; if there can be more than one, the list of directories is returned as a table array of strings. Currently, only ``list``, ``system_data``, and ``system_config`` return more than one.

   .. rubric:: Raises:
      :name: raises-36

   If there is no standard directory of the given kind, returns ``nil``.


 .. _`get_host_name`:

 **get_host_name ()**
   Obtain current host name. This is a wrapper for ``g_get_host_name()``.

   .. rubric:: Returns:
      :name: returns-74

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The local host name. This is not guaranteed to be a unique identifier for the host, or in any way related to its DNS entry.


 .. _`get_current_dir`:

 **get_current_dir ()**
   Obtain current working directory. This is a wrapper for ``g_get_current_dir()``.

   .. rubric:: Returns:
      :name: returns-75

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The current working directory, as an absolute path.


 .. _`path_is_absolute`:

 **path_is_absolute (d)**
   Check if a directory is absolute. This is a wrapper for ``g_path_is_absolute()``.

   .. rubric:: Parameters:
      :name: parameters-76

   -  ``d``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The directory to check

   .. rubric:: Returns:
      :name: returns-76

   **boolean** True if d is absolute; false otherwise.


 .. _`path_split_root`:

 **path_split_root (d)**
   Split the root part from a path. This is a wrapper for ``g_path_skip_root()``.

   .. rubric:: Parameters:
      :name: parameters-77

   -  ``d``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The path to split

   .. rubric:: Returns:
      :name: returns-77

   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **nil** The root part. If the path is not absolute, this will be ``nil``.
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The non-root part


 .. _`path_get_basename`:

 **path_get_basename (d)**
   Obtain the last element of a path. This is a wrapper for ``g_path_get_basename()``. Note that if the last element of a path is blank, this may return the second-to-last element. Also, if this is simply a directory separator, the directory separator is returned. In other words, it is not possible to reconstruct the original file name by appending results from this function.

   .. rubric:: Parameters:
      :name: parameters-78

   -  ``d``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The path to split

   .. rubric:: Returns:
      :name: returns-78

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The last path element of the path


 .. _`path_get_dirname`:

 **path_get_dirname (d)**
   Obtain all but the last element of a path. This is a wrapper for ``g_path_dirname()``. Note that if there is no parent element, and the path is relative, . may be returned. If the path is absolute, the absolute prefix may be returned even if it is the only element present. If there is a terminating directory separator, this may return the same path element as `path_get_basename`_                       .

   .. rubric:: Parameters:
      :name: parameters-79

   -  ``d``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The path to split

   .. rubric:: Returns:
      :name: returns-79

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ All but the last element of the path.


 .. _`build_filename`:

 **build_filename (...)**
   Construct a file name from its path constituents. This is a wrapper for ``g_build_filenamev()``. There is no inverse operation, but it can be implemented in Lua:

   ::

      -- assumes multiple consecutive directory separators are the same as
      -- just one separator (true on non-root in Windows and everywhere in UNIX)
      -- but as a counterexample, AmigaOS has no . and .., but instead uses
      -- blank to mean both:
      --    "" == UNIX .  "/x" == ../x "x///y" == UNIX x/../../y
      function split_filename(f)
          local res = {}
          local r
          r, f = glib.path_split_root(f)
          -- note: it may be a good idea to trim r as well:
          --  convert ^[dir_sep]+$ to dir_sep[0] (strip duplicate dir_sep)
          --  convert ^([^dir_sep].*?)[dir_sep]*$ to \1 (stip trailing dir_sep)
          local rx = glib.regex_new('[' .. glib.regex_escape_string(glib.dir_separator) .. ']')
          local i, e, laste
          for i, e in ipairs(rx:split(f)) do
              if e ~= '' then table.insert(res, e) end
              laste = e
          end
          if laste == '' then table.insert(res, '') end
      end

   .. rubric:: Parameters:
      :name: parameters-80

   -  ``...``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}\|\ `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,... If the first parameter is a table, this table contains a list of path element strings. Otherwise, all parameters are taken to be the path element strings.

   .. rubric:: Returns:
      :name: returns-80

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The result of concatenating all supplied path elements, separated by at most one directory separator as appropriate.


 .. _`build_path`:

 **build_path (sep, ...)**
   Construct a path from its constituents. This is a wrapper for ``g_build_pathv()``. Note that blank elements are simply ignored. If blank elements are required, use Lua instead:

   ::

      function build_path(sep, ...)
          local i, v
          local ret = ''
           for i, v in ipairs{...} do
             if i > 1 then ret = ret .. sep end
             ret = ret .. v
           end
      end

   Also, there is no inverse function. This can be emulated using `regex:split`_                 :

   ::

      function split_path(p, sep)
         local rx = glib.regex_new(glib.regex_escape_string(sep))
         return rx:split(p)
      end

   .. rubric:: Parameters:
      :name: parameters-81

   -  ``sep``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The path element separator
   -  ``...``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}\|\ `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,... If the first parameter is a table, this table contains a list of path element strings. Otherwise, all parameters are taken to be the path element strings.

   .. rubric:: Returns:
      :name: returns-81

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The result of concatenating all supplied path elements, separated by at most one path separator.

   .. rubric:: see also:
      :name: see-also-28

   `build_filename`_                   


 .. _`path_canonicalize`:

 **path_canonicalize (f)**
   Canonicalize a path name. This does not wrap anything in GLib, as GLib does not provide such a function. This function converts a path name to an absolute path name with all relative path references (i.e., . and ..) removed and symbolic links resolved. Additional steps are taken on Windows in an attempt to resolve the myriad of ways a path name may be specified, including short-to-long name conversion, case normalization (for path elements which exist), and UNC format consolidation. Note that
   there are several unresolvable issues: On Windows, there may be host names in the path, which are hard to resolve even with DNS. Also, both Windows and UNIX might have the same path mounted in two different places, and sometimes it's hard to tell that they are the same (and no extra effort is put into checking, either).

   .. rubric:: Parameters:
      :name: parameters-82

   -  ``f``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The file name

   .. rubric:: Returns:
      :name: returns-82

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The canonicalized file name. Note that on Windows, the canonical name always uses backslashes for directory separators.

   .. rubric:: Raises:
      :name: raises-37

   Returns ``nil`` followed by an error message if there is a problem


 .. _`qsort`:

 **qsort (t[, cmp])**
   Sort a table using a stable quicksort algorithm. This is a wrapper for ``g_qsort_with_data()``. This sorts a table in-place the same way as `table.sort <http://www.lua.org/manual/5.1/manual.html#pdf-table.sort>`__ does, but it performs an extra comparison if necessary to determine of two elements are equal (i.e., *cmp*\ (a, b) == *cmp*\ (b, a) == false). If so, they are sorted in the order they appeared in the original table. The extra comparison can be avoided by returning a number instead
   of a boolean from the comparison function; in this case, the number's relationship with 0 indicates a's relationship with b.

   .. rubric:: Parameters:
      :name: parameters-83

   -  ``t``: `table <http://www.lua.org/manual/5.1/manual.html#5.5>`__ Table to sort
   -  ``cmp``: **function** Function to use for comparison; takes two table elements and returns true if the first is less than the second. If not specified, Lua's standard less-than operator is used. The function may also return an integer instead of a boolean, in which case the number must be 0, less than 0, or greater than 0, indicating a is equal to, less than, or greater than b, respectively.

   .. rubric:: see also:
      :name: see-also-29

   -  `utf8_collate`_                 
   -  `cmp`_        


 .. _`cmp`:

 **cmp (a, b)**
   Compare two objects. This function returns the difference between two objects. If the *sub* operation is available in the first object's metatable, that is called. Otherwise, if both parameters are numbers, they are subtracted. Otherwise, if they are both strings, they are byte-wise compared and their relative order is returned. Finally, as a last resort, the standard less-than operator is used, possibly twice, to indicate relative order.

   .. rubric:: Parameters:
      :name: parameters-84

   -  ``a``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The first object
   -  ``b``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The second object

   .. rubric:: Returns:
      :name: returns-83

   **integer** Greater than zero if *a* is greater than *b*; less than zero if *a* is less than *b*; zero if *a* is equal to *b*.

   .. rubric:: see also:
      :name: see-also-30

   `utf8_collate`_                 

_`Timers`
---------


 .. _`timer_new`:

 **timer_new ()**
   Create a stopwatch-like timer. This is a wrapper for ``g_timer_new()``.

   .. rubric:: Returns:
      :name: returns-84

   `timer`_                 A timer object

Class _`timer`
--------------


 .. _`timer:start`:

 **timer:start ()**
   Start or reset the timer. This is a wrapper for ``g_timer_start()``.

 .. _`timer:stop`:

 **timer:stop ()**
   Stop the timer if it is running. This is a wrapper for ``g_timer_stop()``.

 .. _`timer:continue`:

 **timer:continue ()**
   Resume the timer if it is stopped. This is a wrapper for ``g_timer_continue()``.

 .. _`timer:elapsed`:

 **timer:elapsed ()**
   Return the amount of time counted so far. This is a wrapper for ``g_timer_elapsed()``.

   .. rubric:: Returns:
      :name: returns-85

   **number** The time counted so far, in seconds.

_`Spawning Processes`
---------------------


 .. _`spawn`:

 **spawn (args)**
   Run a command asynchronously. This is a wrapper for ``g_spawn_async_with_pipes()``. The other spawn functions can easily be emulated using this.

   .. rubric:: Parameters:
      :name: parameters-85

   -  ``args``: `table <http://www.lua.org/manual/5.1/manual.html#5.5>`__ \|\ `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__

      If the parameter is a string, parse the string as a shell command and execute it. Otherwise, the command is taken from the table. If the table has no array component, the command must be specified using the *cmd* field. Otherwise, the array elements specify the argument vector of the command. If both are provided, the command to actually execute is *cmd*, but the first array element is still passed in as the proposed process name. In addition to the command arguments and *cmd* field, the
      following fields specify options for the spawned command:

      **stdin**: file|string|boolean (default = false)
         Specify the standard input to the process. If this is a file descriptor, it must be opened in read mode; its contents will be the process' standard input. If this is a string, it names a file to be opened for reading. The file name may be blank to indicate that the standard input should be inherited from the current process. The file name may be prefixed with an exclamation point to open in binary mode; otherwise it is opened in normal (text) mode. Any other value is evaluated as a
         boolean; true means that a pipe should be opened such that proc:write() writes to the process, and false means that no standard input should be provided at all (equivalent to UNIX /dev/null).
      **stdout**: file|string|boolean (default = true)
         Specify the standard output for the process. If this is a file descriptor, it must be opened in write mode; the process' standard output will be written to that file. If this is a string, it names a file to be opened for appending. The file name may be blank to indicate that the standard output should be inherited from the current process. The file name may be prefixed with an exclamation point to open in binary mode; otherwise it is opened in normal (text) mode. Any other value is
         evaluated as a boolean; true means that a pipe should be opened such that proc:read() reads from the process, and false means that standard output should be ignored.
      **stderr**: file|string|boolean (default = “”)
         Specify the standard error for the process. See the **stdout** description for details; the only difference is in which functions are used to read from the pipe (read_err and friends).
      **env**: table
         Specify the environment for the process. If this is not provided, the environment is inherited from the parent. Otherwise, all keys in the table correspond to variables, and the values correspond to those variables' values. Only these variables will be set in the spawned process.
      **path**: boolean (default = true)
         If this is present and false, do not use the standard system search path to find the command to execute.
      **chdir**: string
         If this is present, change to the given directory when executing the commmand. Otherwise, it will execute in the current working directory.
      **cmd**: string
         If this is present, and there are no array entries in this table, it is parsed as a shell command to construct the command to run. Otherwise, it is the command to execute instead of the first element of the argument array.

   .. rubric:: Usage:
      :name: usage-7

   ::

      -- fully quoted arguments
      p = glib.spawn {'cat', f}
      f_cont = p:wait()

      -- generic command line; parsed by glib rather than shell so relatively safe
      p = glib.spawn{cmd='cat /tmp/xyz'}
      -- or p = glib.spawn('cat /tmp/xyz')
      xyz_cont = p:wait()

      -- fully quoted arguments, but with renamed argv[0] if supported
      p = glib.spawn{'concatenate', f, cmd='/bin/cat'}
      f_cont = p:wait()

      -- write output to a file
      -- more portable than tacking >file to the command
      of = open('/tmp/of', 'w')
      p = glib.spawn{'cat', f, stdout=of}
      p:wait()
      of:close()

   .. rubric:: Returns:
      :name: returns-86

   `process`_                   An object representing the process.

   .. rubric:: see also:
      :name: see-also-31

   `shell_parse_argv`_                     

Class _`process`
----------------


 .. _`process:read_ready`:

 **process:read_ready (...)**
   Check if input is available from process standard output. This function is used to support non-blocking input from the process. It takes the same parameters as `process:read`_                  , and returns true if that read would succeed without blocking. Otherwise, it returns false (immediately). It accomplishes this by attempting the requested read in a background thread, and returning success when the data has actually been read. Due to buffer sizes used and other issues, the reader
   thread might hang waiting for input even when enough data is available, depending on operating system. On Linux, at least, it should never hang. Note that it is not necessary to use the same arguments for a subsequent `process:read`_                  . For example, the entire file can be pre-read using ``read_ready('*a')``, followed by reading one line at a time. Attempting to read more than a prior ``read_ready`` may cause the system to wait for further input.

   .. rubric:: Parameters:
      :name: parameters-86

   -  ``...``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** See `process:read`_                  for details. For the ‘\*n' format, since it is difficult to tell how much input will be required, the thread will read until it finds a non-blank word.

   .. rubric:: Returns:
      :name: returns-87

   **boolean** True if reading using the given format(s) will succeed without blocking.

   .. rubric:: see also:
      :name: see-also-32

   `process:read`_                 


 .. _`process:read_err_ready`:

 **process:read_err_ready (...)**
   Check if input is available from process standard error. See the documentation for `process:read_ready`_                        for details.

   .. rubric:: Parameters:
      :name: parameters-87

   -  ``...``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** See `process:read_ready`_                        for details.

   .. rubric:: Returns:
      :name: returns-88

   **boolean** True if reading using the given format(s) will succeed without blocking.

   .. rubric:: see also:
      :name: see-also-33

   `process:read_ready`_                       


 .. _`process:read`:

 **process:read (...)**
   Read data from a process' standard output. This function is a clone of the standard Lua ``file:read`` function. It defers actual I/O to the `process:read_ready`_                        routine, which in turn lets a background thread do all of the reading. It will block until `process:read_ready`_                        is true, and then read directly from the buffer filled by the thread.

   .. rubric:: Parameters:
      :name: parameters-88

   -  ``...``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number**

      If no parameters are given, read a single newline-terminated line from input, and strip the trailing newline. Otherwsie, for each parameter, until failure, a result is read and returned based on the parameter. If the parameter is a number, then that many bytes (or fewer) are read. Otherwise, the parameter must be a string containing one of the following:

      -  ‘\*l' – read a line in the same way as the empty argument list does.
      -  ‘\*n' – read a number from input; in this case, a number is returned instead of a string.
      -  ‘\*a' – read the entire remainder of the input. Note that if this is given as a format to `process:read_ready`_                        , all standard output from the process will be read as soon as it is available.

   .. rubric:: Returns:
      :name: returns-89

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** \|\ **nil...** For each parameter (or for the line read by the empty parameter list), the results of reading that format are returned. If an error occurred for any parameter, ``nil`` is returned for that parameter and no further parameters are processed.

   .. rubric:: see also:
      :name: see-also-34

   `process:read_ready`_                       


 .. _`process:read_err`:

 **process:read_err (...)**
   Read data from a process' standard error. See the `process:read`_                  function documentation for details.

   .. rubric:: Parameters:
      :name: parameters-89

   -  ``...``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** See the read function documentation for details.

   .. rubric:: Returns:
      :name: returns-90

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** \|\ **nil...** See the read function documentation for details.

   .. rubric:: see also:
      :name: see-also-35

   `process:read`_                 


 .. _`process:lines`:

 **process:lines ()**
   Return an iterator which reads lines from the process' standard output. On each iteration, this returns the result of `process:read`_                  ().

   .. rubric:: Returns:
      :name: returns-91

   **function** The iterator.

   .. rubric:: see also:
      :name: see-also-36

   `process:read`_                 


 .. _`process:lines_err`:

 **process:lines_err ()**
   Return an iterator which reads lines from the process' standard error. On each iteration, this returns the result of `process:read_err`_                      ().

   .. rubric:: Returns:
      :name: returns-92

   **function** The iterator.

   .. rubric:: see also:
      :name: see-also-37

   `process:read_err`_                     


 .. _`process:write_ready`:

 **process:write_ready ()**
   Check if writing to the process' standard input will block. Writing to a process' standard input is made non-blocking by running writes in a background thread.

   .. rubric:: Returns:
      :name: returns-93

   **boolean** True if a call to process:write() will not block.

   .. rubric:: see also:
      :name: see-also-38

   `process:write`_                  


 .. _`process:write`:

 **process:write (...)**
   Write to a process' standard input. Writes all arguments to the process' standard input. It does this using a background writer thread that writes each argument before allowing the next write. In other words, the first write will not block, but subsequent writes will bock until the previous write has completed.

   .. rubric:: Parameters:
      :name: parameters-90

   -  ``...``: **string...** All strings are written, in the order given.

   .. rubric:: Returns:
      :name: returns-94

   **boolean** Returns true on success. However, since the write has not truly completed until the background writer has finished, the only way to ensure that writing was complete and successful is to use `process:write_ready`_                         or `process:io_wait`_                     .

   .. rubric:: see also:
      :name: see-also-39

   `process:write_ready`_                        


 .. _`process:close`:

 **process:close ()**
   Close the process' standard input channel. This function flushes any pending writes and closes the input channel. Many processes which take input from standard input need this to detect the end of input in order to continue processing.

 .. _`process:io_wait`:

 **process:io_wait ([check_in[, check_out[, check_err]]])**
   Check for process activity. Check to see if I/O is in progress or the process has died.

   .. rubric:: Parameters:
      :name: parameters-91

   -  ``check_in``: **boolean** Return a flag indicating if the background standard input writer is idle.
   -  ``check_out``: **boolean** Return a flag indicating if the background standard output reader is idle.
   -  ``check_err``: **boolean** Return a flag indicating if the background standard error reader is idle.

   .. rubric:: Returns:
      :name: returns-95

   #. **boolean** True if the standard input thread is idle; only returned if requested
   #. **boolean** True if the standard output thread is idle; only returned if requested
   #. **boolean** True if the standard error thread is idle; only returned if requested
   #. **boolean** True if the process is no longer running.


 .. _`process:pid`:

 **process:pid ()**
   Return the glib process ID for the process. Using the process ID for anything other than printing debug messages is non-portable.

   .. rubric:: Returns:
      :name: returns-96

   **number** GLib process ID (which may or may not correspond to a system process ID)


 .. _`process:status`:

 **process:status ()**
   Return the status of the running process.

   .. rubric:: Returns:
      :name: returns-97

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** If the process is running, the string ``running`` is returned. Otherwise, the numeric exit code from the process is returned.


 .. _`process:check_exit_status`:

 **process:check_exit_status ()**
   Check if the process return code was an error.

   This is only available with GLib 2.34 or later.

   .. rubric:: Returns:
      :name: returns-98

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **nil** If the status returned by `process:status`_                    should be interpreted as an error, a human-readable error message is returned. If the process has not yet finished, or the return code is considered successful, ``nil`` is returned.


 .. _`process:wait`:

 **process:wait ()**
   Wait for process termination and clean up. This function starts background reads for all data on the standard output and standard error channels, and flushes and closes the standard input channel. It then waits for the process to finish. Once finished, the result code from the process and any gathered standard output and standard error are returned.

   .. rubric:: Returns:
      :name: returns-99

   #. **number** Result code from the process
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ If a standard output pipe was in use, this is the remaining data on the pipe.
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ If a standard error pipe was in use, this is the reaming data on the pipe.

_`File Utilities`
-----------------


 .. _`file_get`:

 **file_get (name)**
   Return contents of a file as a string. This function is a wrapper for ``g_file_get_contents()``. It is mostly equivalent to ``io.open(``\ *name*\ ``):read('*a')``.

   .. rubric:: Parameters:
      :name: parameters-92

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Name of file to read

   .. rubric:: Returns:
      :name: returns-100

   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **nil** Contents of file, or nil if there was an error.
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Error message if there was an error.


 .. _`file_set`:

 **file_set (name, contents)**
   Set contents of a file to a string. This function is a wrapper for ``g_file_set_contents()``. Rather than write directly to a file, it writes to a temporary first and then moves the result into place. In other words, it is *not* equivalent to ``io.open(``\ *name*\ ``, 'w'):write(``\ *contents*\ ``)``.

   .. rubric:: Parameters:
      :name: parameters-93

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Name of file to write
   -  ``contents``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Contents to write

   .. rubric:: Returns:
      :name: returns-101

   **boolean** True if successful

   .. rubric:: Raises:
      :name: raises-38

   Returns false and error message string on error.


 .. _`is_file`:

 **is_file (name)**
   Test if the given path points to a file. This function is a wrapper for ``g_file_test()``.

   .. rubric:: Parameters:
      :name: parameters-94

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The path name to test

   .. rubric:: Returns:
      :name: returns-102

   **boolean** true if *name* names a plain file


 .. _`is_dir`:

 **is_dir (name)**
   Test if the given path points to a directory. This function is a wrapper for ``g_file_test()``.

   .. rubric:: Parameters:
      :name: parameters-95

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The path name to test

   .. rubric:: Returns:
      :name: returns-103

   **boolean** true if *name* names a plain file


 .. _`is_symlink`:

 **is_symlink (name)**
   Test if the given path points to a symbolic link. This function is a wrapper for ``g_file_test()``. Note that if this returns true, the is_dir and is_file tests may still return true as well, since they follow symbolic links.

   .. rubric:: Parameters:
      :name: parameters-96

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The path name to test

   .. rubric:: Returns:
      :name: returns-104

   **boolean** true if *name* names a symbolic link


 .. _`is_exec`:

 **is_exec (name)**
   Test if the given path points to an executable file. This function is a wrapper for ``g_file_test()``. Note that GLib uses heuristics on Windows, since there is no executable bit to test.

   .. rubric:: Parameters:
      :name: parameters-97

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The path name to test

   .. rubric:: Returns:
      :name: returns-105

   **boolean** true if *name* names an executable file.


 .. _`exists`:

 **exists (name)**
   Test if the given path points to a file or directory. This function is a wrapper for ``g_file_test()``. Note that invalid symbolic links return false, even though they actually exist.

   .. rubric:: Parameters:
      :name: parameters-98

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The path name to test

   .. rubric:: Returns:
      :name: returns-106

   **boolean** true if *name* exists in the file system


 .. _`umask`:

 **umask ([mask])**
   Change default file and directory creation permissions mask. This is a wrapper for the system ``umask()`` function, since there is no equivalent in GLib.

   .. rubric:: Parameters:
      :name: parameters-99

   -  ``mask``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** The permissions mask. Permissions set in this mask are forced off in any newly created files and directories. Either a numeric permissions mask or a POSIX-sytle mode string (e.g. ‘og=w', which is the default if this parameter is unspecified) or the last 9 characters of long directory listing mode (e.g. ‘—-w–w-', which is also the default).

   .. rubric:: Returns:
      :name: returns-107

   **number** The previous mask.


 .. _`mkstemp`:

 **mkstemp (tmpl[, perm])**
   Create a unique temporary file from a pattern. This function is a wrapper for ``g_mkstemp()``. It creates a new, unique file by replacing the X characters in a template containing six consecutive X characters.

   .. rubric:: Parameters:
      :name: parameters-100

   -  ``tmpl``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The template.
   -  ``perm``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** File creation permissions. Either a numeric permission mask or a POSIX-style mode string (e.g. ‘ug=rw') or the last 9 characters of long directory listing mode (e.g. ‘rwxr-xr-x')

   .. rubric:: Returns:
      :name: returns-108

   #. **file** A file descriptor for the newly created file, open for reading and writing (``w+b``).
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name of the created file.

   .. rubric:: Raises:
      :name: raises-39

   Returns ``nil`` and error message string on error.


 .. _`open_tmp`:

 **open_tmp ([tmpl])**
   Create a unique temporary file in the standard temporary directory. This function is a wrapper for ``g_file_open_tmp()``. It creates a new, unique file by replacing the X characters in a template containing six consecutive X characters. The template may contain no directory separators.

   .. rubric:: Parameters:
      :name: parameters-101

   -  ``tmpl``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The template. If unspecified, a default template will be used.

   .. rubric:: Returns:
      :name: returns-109

   #. **file** A file descriptor for the newly created file, open for reading and writing (``w+b``).
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The full path name of the created file.

   .. rubric:: Raises:
      :name: raises-40

   Returns ``nil`` and error message string on error.


 .. _`read_link`:

 **read_link (name)**
   Read the contents of a soft link. This is a wrapper for ``g_file_read_link()``.

   .. rubric:: Parameters:
      :name: parameters-102

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Link to read

   .. rubric:: Returns:
      :name: returns-110

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Link contents

   .. rubric:: Raises:
      :name: raises-41

   Returns ``nil`` and error message string on error.


 .. _`mkdir_with_parents`:

 **mkdir_with_parents (name[, mode])**
   Create a directory and any required parent directories. This is a wrapper for ``g_mkdir_with_parents()``.

   .. rubric:: Parameters:
      :name: parameters-103

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Name of directory to create.
   -  ``mode``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** File permissions. Either a numeric creation mode or a POSIX-style mode string (e.g. ‘ug=rw') or the last 9 characters of long directory listing mode (e.g. ‘rwxr-xr-x'). If unspecified, ‘a=rx,u=w' is used (octal 755; ‘rwxr-xr-x')).

   .. rubric:: Returns:
      :name: returns-111

   **boolean** True

   .. rubric:: Raises:
      :name: raises-42

   Returns false and error message string on error.


 .. _`mkdtemp`:

 **mkdtemp (tmpl[, mode])**
   Create a unique tempoarary directory from a pattern. This is a wrapper for ``g_mkdtemp``. It replaces 6 consecutive Xs in the pattern with a unique string and creates a directory by that name.

   This is only available with GLib 2.30 or later.

   .. rubric:: Parameters:
      :name: parameters-104

   -  ``tmpl``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The file name pattern
   -  ``mode``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** File permissions. Either a numeric creation mode or a POSIX-style mode string (e.g. ‘ug=rw') or the last 9 characters of long directory listing mode (e.g. ‘rwxr-xr-x').

   .. rubric:: Returns:
      :name: returns-112

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name of the created directory

   .. rubric:: Raises:
      :name: raises-43

   Returns ``nil`` and error message string on error.


 .. _`dir_make_tmp`:

 **dir_make_tmp ([tmpl])**
   Create a unique temporary directory in the standard temporary directory. This is a wrapper for ``g_dir_make_tmp()``. It creates a new, unique directory in the standard temporary directory by replacing 6 consecutive Xs in the template.

   This is only available with GLib 2.30 or later.

   .. rubric:: Parameters:
      :name: parameters-105

   -  ``tmpl``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The template. If unspecified, a default template will be used.

   .. rubric:: Returns:
      :name: returns-113

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name of the created directory

   .. rubric:: Raises:
      :name: raises-44

   Returns ``nil`` and error message string on error.


 .. _`dir`:

 **dir (d)**
   Returns an iterator which lists entries in a directory. This function wraps ``g_dir_open()`` and friends.

   .. rubric:: Parameters:
      :name: parameters-106

   -  ``d``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The directory to list

   .. rubric:: Returns:
      :name: returns-114

   **function** Iterator

   .. rubric:: Raises:
      :name: raises-45

   Returns ``nil`` and error message string on error.


 .. _`rename`:

 **rename (old, new)**
   Rename a file sytem entity. This is a wrapper for ``g_rename()``.

   .. rubric:: Parameters:
      :name: parameters-107

   -  ``old``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The old name
   -  ``new``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The new name

   .. rubric:: Returns:
      :name: returns-115

   **boolean** True

   .. rubric:: Raises:
      :name: raises-46

   Returns false and error message string on error.


 .. _`mkdir`:

 **mkdir (name[, mode])**
   Create a directory. This is a wrapper for ``g_mkdir()``.

   .. rubric:: Parameters:
      :name: parameters-108

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name of the directory.
   -  ``mode``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** File permissions. Either a numeric creation mode or a POSIX-style mode string (e.g. ‘ug=rw') or the last 9 characters of long directory listing mode (e.g. ‘rwxr-xr-x'). The default is ‘a=rx,u=w' (octal 755, ‘rwxr-xr-x').

   .. rubric:: Returns:
      :name: returns-116

   **boolean** True

   .. rubric:: Raises:
      :name: raises-47

   Returns false and error message string on error.


 .. _`stat`:

 **stat (name[, fields])**
   Retrieve information on a file system entry. This is a wrapper for ``g_stat()``. If a table is given to specify fields, only those fields are returned (nil if not present) as multiple results. Otherwise, a table is returned with all known fields and their values. If the field named ‘link' is requested, it is not an actual field, but an indicator to return information about a soft link rather than what it points to.

   .. rubric:: Parameters:
      :name: parameters-109

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The file system entry to query
   -  ``fields``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}\|\ `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,... The fields to query, in order.

   .. rubric:: Returns:
      :name: returns-117

   #. `table <http://www.lua.org/manual/5.1/manual.html#5.5>`__ A table whose keys are field names and whose values are the value for that field, if either no specific values are requested or the only value requested is the psuedo-value ‘link'.
   #. **number** \|\ `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **nil** The value of each field; multiple values may be returned. Unknown fields return ``nil``.

   .. rubric:: Raises:
      :name: raises-48

   Returns ``nil`` and error message string on error.


 .. _`remove`:

 **remove (name)**
   Remove a file sytem entity. This is a wrapper for ``g_remove()``. For recursive removal, use Lua:

   ::

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
               gmsg = msg
          end
          if err then
               return false, gmsg
          else
               return true
          end
      end

   .. rubric:: Parameters:
      :name: parameters-110

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The entity to remove

   .. rubric:: Returns:
      :name: returns-118

   **boolean** True on success.

   .. rubric:: Raises:
      :name: raises-49

   Returns false and an error message string on failure. Note that the error message is probably invalid if the entity was not a directory.


 .. _`chmod`:

 **chmod (name, perm)**
   Change filesystem entry permissions. This is a wrapper for ``g_chmod()``. In addition, it will query the original file for information if a string-style permission is used.

   .. rubric:: Parameters:
      :name: parameters-111

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The filesystem entry to modify
   -  ``perm``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **number** Permissions to set.

   .. rubric:: Returns:
      :name: returns-119

   **boolean** True

   .. rubric:: Raises:
      :name: raises-50

   Returns false and error message string on error.


 .. _`can_read`:

 **can_read (name)**
   Test if fileystem object can be read. This is a wrapper for ``g_access()``. Note that this function does not necessarily check access control lists, so it may be better to just test open/read the file.

   .. rubric:: Parameters:
      :name: parameters-112

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Name of object to test

   .. rubric:: Returns:
      :name: returns-120

   #. **boolean** true if *name* can be read.
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ message if *name* cannot be read.
   #. **number** error number if *name* cannot be read.


 .. _`can_write`:

 **can_write (name)**
   Test if fileystem object can be written to. This is a wrapper for ``g_access()``. Note that this function does not necessarily check access control lists, so it may be better to just test open/write the file.

   .. rubric:: Parameters:
      :name: parameters-113

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Name of object to test

   .. rubric:: Returns:
      :name: returns-121

   #. **boolean** true if *name* can be written to.
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ message if *name* cannot be written to.
   #. **number** error number if *name* cannot be written to.


 .. _`chdir`:

 **chdir (dir)**
   Change current working directory. This is a wrapper for ``g_chdir()``.

   .. rubric:: Parameters:
      :name: parameters-114

   -  ``dir``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Name of directory to change into

   .. rubric:: Returns:
      :name: returns-122

   **boolean** True

   .. rubric:: Raises:
      :name: raises-51

   Returns false and error message string on error.


 .. _`utime`:

 **utime (name[, atime[, mtime]])**
   Change timestamp on filesystem object. This is a wrapper for ``g_utime()``.

   .. rubric:: Parameters:
      :name: parameters-115

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Name of entry to touch
   -  ``atime``: **number** \|\ **nil** access time; *mtime* is used if not present. Note that *atime* may not be supported by the target file system entry; no error is returned even if that is the case.
   -  ``mtime``: **number** \|\ **nil** modification time; current time is used if neither *atime* nor *mtime* present; left alone if *atime* present but *mtime* not present

   .. rubric:: Returns:
      :name: returns-123

   **boolean** True

   .. rubric:: Raises:
      :name: raises-52

   Returns false and error message string on error.


 .. _`link`:

 **link (target, name[, soft])**
   Create a link. This is not a wrapper for any GLib function, since GLib does not support links portably. It creates a hard link or soft link, if supported. Note that on Windows, whether or not the target is a directory must be known at link creation time. This is discovered by checking the target.

   .. rubric:: Parameters:
      :name: parameters-116

   -  ``target``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The link's target
   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name of the link to create
   -  ``soft``: **boolean** If true, create a soft link

   .. rubric:: Returns:
      :name: returns-124

   **boolean** True

   .. rubric:: Raises:
      :name: raises-53

   Returns False and an error message string on failure

_`URI Functions`
----------------


 .. _`uri_reserved_chars_allowed_in_path`:

 **uri_reserved_chars_allowed_in_path**
   Allowed characters in a path. This is a wrapper for ``G_URI_RESERVED_CHARS_ALLOWED_IN_PATH``.

 .. _`uri_reserved_chars_allowed_in_path_element`:

 **uri_reserved_chars_allowed_in_path_element**
   Allowed characters in path elements. This is a wrapper for ``G_URI_RESERVED_CHARS_ALLOWED_IN_PATH_ELEMENT``.

 .. _`uri_reserved_chars_allowed_in_userinfo`:

 **uri_reserved_chars_allowed_in_userinfo**
   Allowed characters in userinfo (RFC 3986). This is a wrapper for ``G_URI_RESERVED_CHARS_ALLOWED_IN_USERINFO``.

 .. _`uri_reserved_chars_generic_delimiters`:

 **uri_reserved_chars_generic_delimiters**
   Generic delimiter characters (RFC 3986). This is a wrapper for ``G_URI_RESERVED_CHARS_GENERIC_DELIMITERS``.

 .. _`uri_reserved_chars_subcomponent_delimiters`:

 **uri_reserved_chars_subcomponent_delimiters**
   Subcomponent delimiter characters (RFC 3986). This is a wrapper for ``G_URI_RESERVED_CHARS_SUBCOMPONENT_DELIMITERS``.

 .. _`uri_parse_scheme`:

 **uri_parse_scheme (uri)**
   Extract scheme from URI. This is a wrapper for ``g_uri_parse_scheme()``.

   .. rubric:: Parameters:
      :name: parameters-117

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The valid URI

   .. rubric:: Returns:
      :name: returns-125

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The scheme

   .. rubric:: Raises:
      :name: raises-54

   Returns ``nil`` on error.


 .. _`uri_escape_string`:

 **uri_escape_string (s[, allow[, utf8]])**
   Escapes a string for use in a URI. This is a wrapper for ``g_uri_escape_string()``.

   .. rubric:: Parameters:
      :name: parameters-118

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to esacape; nuls are not allowed.
   -  ``allow``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Reserved characters to leave unescaped anyway.
   -  ``utf8``: **boolean** Allow UTF-8 characters in result.

   .. rubric:: Returns:
      :name: returns-126

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The escaped string.


 .. _`uri_unescape_string`:

 **uri_unescape_string (s[, illegal])**
   Unescapes an escaped string. This is a wrapper for ``g_uri_unescape_string()``.

   .. rubric:: Parameters:
      :name: parameters-119

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to unescape
   -  ``illegal``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Characters which may not appear in the result; nul characters are automatically illegal.

   .. rubric:: Returns:
      :name: returns-127

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The unescaped string.

   .. rubric:: Raises:
      :name: raises-55

   Returns ``nil`` on error.


 .. _`uri_list_extract_uris`:

 **uri_list_extract_uris (list)**
   Splits an URI list conforming to the text/uri-list MIME type (RFC 2483). This is a wrapper for ``g_uri_list_extract_uris()``.

   .. rubric:: Parameters:
      :name: parameters-120

   -  ``list``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI list

   .. rubric:: Returns:
      :name: returns-128

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}A table containing the URIs


 .. _`filename_from_uri`:

 **filename_from_uri (uri)**
   Converts an ASCII-encoded URI to a local filename. This is a wrapper for ``g_filename_from_uri()``.

   .. rubric:: Parameters:
      :name: parameters-121

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-129

   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The file name
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **nil** The host name, or ``nil`` if none

   .. rubric:: Raises:
      :name: raises-56

   Returns ``nil`` and error message string on error.


 .. _`filename_to_uri`:

 **filename_to_uri (file[, host])**
   Converts an absolute filename to an escaped ASCII-encoded URI. This is a wrapper for ``g_filename_to_uri()``.

   .. rubric:: Parameters:
      :name: parameters-122

   -  ``file``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The filename
   -  ``host``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The host name

   .. rubric:: Returns:
      :name: returns-130

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Raises:
      :name: raises-57

   Returns ``nil`` and error message string on error.

_`Hostname Utilities`
---------------------


 .. _`hostname_to_ascii`:

 **hostname_to_ascii (hostname)**
   Convert a host name to its canonical ASCII form. This is a wrapper for ``g_hostname_to_ascii()``.

   .. rubric:: Parameters:
      :name: parameters-123

   -  ``hostname``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name to convert

   .. rubric:: Returns:
      :name: returns-131

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The converted name

   .. rubric:: Raises:
      :name: raises-58

   Returns ``nil`` on error.


 .. _`hostname_to_unicode`:

 **hostname_to_unicode (hostname)**
   Convert a host name to its canonical Unicode form. This is a wrapper for ``g_hostname_to_unicode()``.

   .. rubric:: Parameters:
      :name: parameters-124

   -  ``hostname``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name to convert

   .. rubric:: Returns:
      :name: returns-132

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The converted name

   .. rubric:: Raises:
      :name: raises-59

   Returns ``nil`` on error.


 .. _`hostname_is_non_ascii`:

 **hostname_is_non_ascii (hostname)**
   Check if a host name contains Unicode characters. This is a wrapper for ``g_hostname_is_non_ascii()``.

   .. rubric:: Parameters:
      :name: parameters-125

   -  ``hostname``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name to check

   .. rubric:: Returns:
      :name: returns-133

   **boolean** True if the host name needs to be converted to ASCII for non-IDN-aware contexts.


 .. _`hostname_is_ascii_encoded`:

 **hostname_is_ascii_encoded (hostname)**
   Check if a host name contains ASCII-encoded Unicode characters. This is a wrapper for ``g_hostname_is_ascii_encoded()``.

   .. rubric:: Parameters:
      :name: parameters-126

   -  ``hostname``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name to check

   .. rubric:: Returns:
      :name: returns-134

   **boolean** True if the host name needs to be converted to Unicode for presentation and IDN-aware contexts.


 .. _`hostname_is_ip_address`:

 **hostname_is_ip_address (hostname)**
   Check if a string is an IPv4 or IPv6 numeric address. This is a wrapper for ``g_hostname_is_ip_address()``.

   .. rubric:: Parameters:
      :name: parameters-127

   -  ``hostname``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name to check

   .. rubric:: Returns:
      :name: returns-135

   **boolean** True if the host name is actually an IP address

_`Shell-related Utilities`
--------------------------


 .. _`shell_parse_argv`:

 **shell_parse_argv (cmdline)**
   Parse a command line into an argument vector, but without variable and glob pattern expansion. This is a wrapper for ``g_shell_parse_argv()``.

   .. rubric:: Parameters:
      :name: parameters-128

   -  ``cmdline``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The command line to parse

   .. rubric:: Returns:
      :name: returns-136

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}A table containing the command-line arguments

   .. rubric:: Raises:
      :name: raises-60

   Returns ``nil`` and error message string on error.


 .. _`shell_quote`:

 **shell_quote (s)**
   Quote a string so it is interpreted unmodified as a shell argument. This is a wrapper for ``g_shell_quote()``.

   .. rubric:: Parameters:
      :name: parameters-129

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to quote

   .. rubric:: Returns:
      :name: returns-137

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The quoted string


 .. _`shell_unquote`:

 **shell_unquote (s)**
   Unquote a string quoted for use as a shell argument. This is a wrapper for ``g_shell_unquote()``.

   .. rubric:: Parameters:
      :name: parameters-130

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to unquote

   .. rubric:: Returns:
      :name: returns-138

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The unquoted string

   .. rubric:: Raises:
      :name: raises-61

   Returns ``nil`` and error message string on error.

_`Perl-compatible Regular Expressions`
--------------------------------------


 .. _`regex_new`:

 **regex_new (pattern[, cflags[, mflags]])**
   Compile a regular expression for use in matching functions. This is a wrapper for ``g_regex_new()``. See in particular the Regular expression syntax section of the GLib documentation.

   .. rubric:: Parameters:
      :name: parameters-131

   -  ``pattern``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The regular expression. Note that embedded NUL characters are supported.

   -  ``cflags``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}

      Compile flags (note: some may be set by the library based on the pattern input):

      -  ``caseless`` – Case-insensitive search
      -  ``multiline`` – ^ and $ match newlines in search strings
      -  ``dotall`` – . matches newlines
      -  ``extended`` – unescaped whitespace and unescaped # .. newline ignored
      -  ``anchored`` – pattern must match at start of string
      -  ``dollar_endonly`` – $ does not match newline at end of string
      -  ``ungreedy`` – Invert greediness of variable-length matches
      -  ``raw`` – Strings are sequences of bytes rather than UTF-8
      -  ``no_auto_capture`` – Plain () does not capture (use explicitly named captures)
      -  ``optimize`` – Optimize the regular expression
      -  ``dupnames`` – Do not enforce unique subpattern names
      -  ``newline_cr`` – Newlines for $, ^, and . are \\r (default: any).
      -  ``newline_lf`` – Newlines for $, ^, and . are \\n (default: any).
      -  ``newline_crlf`` – Newlines for $, ^, and . are \\r\n (default: any).

   -  ``mflags``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}

      Match flags:

      -  ``anchored`` – pattern must match at start of string
      -  ``notbol`` – ^ does not match the start of string (but \\A does)
      -  ``noteol`` – $ does not match the end of string (but \\Z and \\z do)
      -  ``notempty`` – the match length must be greater than zero
      -  ``partial`` – use partial (incremental) matching; incompatible with ``all``
      -  ``newline_cr`` – Newlines for $, ^, and . are \\r.
      -  ``newline_lf`` – Newlines for $, ^, and . are \\n.
      -  ``newline_crlf`` – Newlines for $, ^, and . are \\r\n.
      -  ``newline_any`` – Newlines for $, ^, and . are any.
      -  ``all`` – changes the behavior of matches from returning captures to returning all potential matches. That is, any variable-length matching operator will attempt to match at every possible length, rather than the most/least greedy depending on the ungreedy option an the ? greediness operator. This is incompatible with captures and partial matching.

   .. rubric:: Returns:
      :name: returns-139

   `regex`_                 The compiled regular expression

   .. rubric:: Raises:
      :name: raises-62

   Returns ``nil`` and error message string on error.


 .. _`regex_escape_string`:

 **regex_escape_string (s)**
   Escapes a string so it is a literal in a regular expression.

   .. rubric:: Parameters:
      :name: parameters-132

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to escape

   .. rubric:: Returns:
      :name: returns-140

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The escaped string.

Class _`regex`
--------------


 .. _`regex:get_pattern`:

 **regex:get_pattern ()**
   Get the pattern string used to create this regex.

   .. rubric:: Returns:
      :name: returns-141

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The pattern string


 .. _`regex:get_max_backref`:

 **regex:get_max_backref ()**
   Get the highest back reference in the pattern.

   .. rubric:: Returns:
      :name: returns-142

   **number** The number of the highest backreference, or 0 if there are none.


 .. _`regex:get_has_cr_or_lf`:

 **regex:get_has_cr_or_lf ()**
   Check if pattern contains explicit CR or LF references.

   This is only available with GLib 2.34 or later.

   .. rubric:: Returns:
      :name: returns-143

   **boolean** true if the pattern contains explicit CR or LF references.


 .. _`regex:get_max_lookbehind`:

 **regex:get_max_lookbehind ()**
   Get the number of characters in the longest lookbehind assertion in the pattern.

   This is only available with GLib 2.38 or later.

   .. rubric:: Returns:
      :name: returns-144

   **number** The number of characters in the longest lookbehind assertion.


 .. _`regex:get_capture_count`:

 **regex:get_capture_count ()**
   Get the number of capturing subpatterns in the pattern.

   .. rubric:: Returns:
      :name: returns-145

   **number** The number of capturing subpatterns.


 .. _`regex:get_string_number`:

 **regex:get_string_number (name)**
   Get the number of the capturing subexpression with the given name.

   .. rubric:: Parameters:
      :name: parameters-133

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The subexpression name

   .. rubric:: Returns:
      :name: returns-146

   **number** The subexpression number, or -1 if *name* does not exist


 .. _`regex:get_compile_flags`:

 **regex:get_compile_flags ()**
   Get the names of all compile flags set when regex was created.

   .. rubric:: Returns:
      :name: returns-147

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}The names of any flags set when regex was created.


 .. _`regex:get_match_flags`:

 **regex:get_match_flags ()**
   Get the names of all matching flags set when regex was created.

   .. rubric:: Returns:
      :name: returns-148

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}The names of any flags set when regex was created.


 .. _`regex:find`:

 **regex:find (s[, start[, mflags]])**
   Search for a match in a string.

   .. rubric:: Parameters:
      :name: parameters-134

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to search

   -  ``start``: **number** The start position.

   -  ``mflags``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}

      Additional match flags:

      -  ``anchored`` – pattern must match at start of string
      -  ``notbol`` – ^ does not match the start of string (but \\A does)
      -  ``noteol`` – $ does not match the end of string (but \\Z does)
      -  ``notempty`` – the match length must be greater than zero
      -  ``partial`` – use partial (incremental) matching; incompatible with ``all``
      -  ``newline_cr`` – Newlines for $, ^, and . are \\r.
      -  ``newline_lf`` – Newlines for $, ^, and . are \\n.
      -  ``newline_crlf`` – Newlines for $, ^, and . are \\r\n.
      -  ``newline_any`` – Newlines for $, ^, and . are any.
      -  ``all`` – changes the behavior of matches from returning captures to returning all potential matches. That is, any variable-length matching operator will attempt to match at every possible length, rather than the most/least greedy depending on the ungreedy option an the ? greediness operator. This is incompatible with captures and partial matching.

   .. rubric:: Returns:
      :name: returns-149

   #. **number** \|\ **nil** \|\ **boolean** The location of the start of the first match, or ``nil`` if there are no matches, or false if there is only a partial match, in which case no further results are returned (the location of the match cannot be determined, and there are no captures).
   #. **number** The location of the last character of the first match
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **boolean** ,...On a successful match, all captures are returned as well. If a capture does not exist, false is returned for that capture. For ``all`` mode, these are actually all possible matches except the maximal match, which is described by the first two return values.

   .. rubric:: Raises:
      :name: raises-63

   Returns ``nil`` and error message string on error.

   .. rubric:: see also:
      :name: see-also-40

   `string.find <http://www.lua.org/manual/5.1/manual.html#pdf-string.find>`__


 .. _`regex:tfind`:

 **regex:tfind (s[, start[, mflags]])**
   Search for a match in a string. Unlike `regex:find`_                , captures are returned in a table rather than as individual return values.

   .. rubric:: Parameters:
      :name: parameters-135

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to search

   -  ``start``: **number** The start position.

   -  ``mflags``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}

      Additional match flags:

      -  ``anchored`` – pattern must match at start of string
      -  ``notbol`` – ^ does not match the start of string (but \\A does)
      -  ``noteol`` – $ does not match the end of string (but \\Z does)
      -  ``notempty`` – the match length must be greater than zero
      -  ``partial`` – use partial (incremental) matching; incompatible with ``all``
      -  ``newline_cr`` – Newlines for $, ^, and . are \\r.
      -  ``newline_lf`` – Newlines for $, ^, and . are \\n.
      -  ``newline_crlf`` – Newlines for $, ^, and . are \\r\n.
      -  ``newline_any`` – Newlines for $, ^, and . are any.
      -  ``all`` – changes the behavior of matches from returning captures to returning all potential matches. That is, any variable-length matching operator will attempt to match at every possible length, rather than the most/least greedy depending on the ungreedy option an the ? greediness operator. This is incompatible with captures and partial matching.

   .. rubric:: Returns:
      :name: returns-150

   #. **number** \|\ **nil** \|\ **boolean** The location of the start of the first match, or ``nil`` if there are no matches, or false if there is only a partial match, in which case no further results are returned (the location of the match cannot be determined, and there are no captures).
   #. **number** The location of the last character of the first match
   #. {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **boolean** ,...}On a successful match, all captures are returned as well. If a capture does not exist, false is returned for that capture. If there are no captures, an empty table is returned. For ``all`` mode, these are actually all possible matches except the maximal match, which is described by the first two return values.

   .. rubric:: Raises:
      :name: raises-64

   Returns ``nil`` and error message string on error.

   .. rubric:: see also:
      :name: see-also-41

   `string.find <http://www.lua.org/manual/5.1/manual.html#pdf-string.find>`__


 .. _`regex:match`:

 **regex:match (s[, start[, mflags]])**
   Search for a match in a string.

   .. rubric:: Parameters:
      :name: parameters-136

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to search

   -  ``start``: **number** The start position.

   -  ``mflags``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}

      Additional match flags:

      -  ``anchored`` – pattern must match at start of string
      -  ``notbol`` – ^ does not match the start of string (but \\A does)
      -  ``noteol`` – $ does not match the end of string (but \\Z does)
      -  ``notempty`` – the match length must be greater than zero
      -  ``partial`` – use partial (incremental) matching; incompatible with ``all``
      -  ``newline_cr`` – Newlines for $, ^, and . are \\r.
      -  ``newline_lf`` – Newlines for $, ^, and . are \\n.
      -  ``newline_crlf`` – Newlines for $, ^, and . are \\r\n.
      -  ``newline_any`` – Newlines for $, ^, and . are any.
      -  ``all`` – changes the behavior of matches from returning captures to returning all potential matches. That is, any variable-length matching operator will attempt to match at every possible length, rather than the most/least greedy depending on the ungreedy option an the ? greediness operator. This is incompatible with captures and partial matching.

   .. rubric:: Returns:
      :name: returns-151

   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **nil** \|\ **boolean** The first capture, or the full match if there are no captures, or ``nil`` if there are no matches, or false if there is only a partial match (in which case there are no captures).
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **boolean** ,...On a successful match, all remaining captures are returned as well. If a capture does not exist, false is returned for that capture. For ``all`` mode, which has no captures, these are all possible matches but the maximal match, which is the first returned string.

   .. rubric:: Raises:
      :name: raises-65

   Returns ``nil`` and error message string on error.

   .. rubric:: see also:
      :name: see-also-42

   `string.match <http://www.lua.org/manual/5.1/manual.html#pdf-string.match>`__


 .. _`regex:gmatch`:

 **regex:gmatch (s[, start[, mflags]])**
   Search for all matches in a string.

   .. rubric:: Parameters:
      :name: parameters-137

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to search

   -  ``start``: **number** The start position.

   -  ``mflags``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...} Additional match flags:

      -  ``anchored`` – pattern must match at start of string
      -  ``notbol`` – ^ does not match the start of string (but \\A does)
      -  ``noteol`` – $ does not match the end of string (but \\Z does)
      -  ``notempty`` – the match length must be greater than zero
      -  ``partial`` – use partial (incremental) matching
      -  ``newline_cr`` – Newlines for $, ^, and . are \\r.
      -  ``newline_lf`` – Newlines for $, ^, and . are \\n.
      -  ``newline_crlf`` – Newlines for $, ^, and . are \\r\n.
      -  ``newline_any`` – Newlines for $, ^, and . are any.

      Note that a regex created using ``all`` will return an error.

   .. rubric:: Returns:
      :name: returns-152

   **function** An iterator function which, on each iteration, returns the same as `regex:match`_                 would have for the next match in the string.

   .. rubric:: see also:
      :name: see-also-43

   -  `string.gmatch <http://www.lua.org/manual/5.1/manual.html#pdf-string.gmatch>`__
   -  `regex:match`_                


 .. _`regex:gfind`:

 **regex:gfind (s[, start[, mflags]])**
   Search for all matches in a string.

   .. rubric:: Parameters:
      :name: parameters-138

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to search

   -  ``start``: **number** The start position.

   -  ``mflags``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...} Additional match flags:

      -  ``anchored`` – pattern must match at start of string
      -  ``notbol`` – ^ does not match the start of string (but \\A does)
      -  ``noteol`` – $ does not match the end of string (but \\Z does)
      -  ``notempty`` – the match length must be greater than zero
      -  ``partial`` – use partial (incremental) matching
      -  ``newline_cr`` – Newlines for $, ^, and . are \\r.
      -  ``newline_lf`` – Newlines for $, ^, and . are \\n.
      -  ``newline_crlf`` – Newlines for $, ^, and . are \\r\n.
      -  ``newline_any`` – Newlines for $, ^, and . are any.

      Note that a regex created using ``all`` will return an error.

   .. rubric:: Returns:
      :name: returns-153

   **function** An iterator function which, on each iteration, returns the same as `regex:find`_                would have for the next match in the string.

   .. rubric:: see also:
      :name: see-also-44

   `regex:find`_               


 .. _`regex:gtfind`:

 **regex:gtfind (s[, start[, mflags]])**
   Search for all matches in a string.

   .. rubric:: Parameters:
      :name: parameters-139

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to search

   -  ``start``: **number** The start position.

   -  ``mflags``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...} Additional match flags:

      -  ``anchored`` – pattern must match at start of string
      -  ``notbol`` – ^ does not match the start of string (but \\A does)
      -  ``noteol`` – $ does not match the end of string (but \\Z does)
      -  ``notempty`` – the match length must be greater than zero
      -  ``partial`` – use partial (incremental) matching
      -  ``newline_cr`` – Newlines for $, ^, and . are \\r.
      -  ``newline_lf`` – Newlines for $, ^, and . are \\n.
      -  ``newline_crlf`` – Newlines for $, ^, and . are \\r\n.
      -  ``newline_any`` – Newlines for $, ^, and . are any.

      Note that a regex created using ``all`` will return an error.

   .. rubric:: Returns:
      :name: returns-154

   **function** An iterator function which, on each iteration, returns the same as `regex:tfind`_                 would have for the next match in the string.

   .. rubric:: see also:
      :name: see-also-45

   `regex:tfind`_                


 .. _`regex:split`:

 **regex:split (s[, start[, mflags[, max]]])**
   Split a string with a regular expression separator.

   .. rubric:: Parameters:
      :name: parameters-140

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to split

   -  ``start``: **number** The start position.

   -  ``mflags``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...} Additional match flags:

      -  ``anchored`` – pattern must match at start of string
      -  ``notbol`` – ^ does not match the start of string (but \\A does)
      -  ``noteol`` – $ does not match the end of string (but \\Z does)
      -  ``notempty`` – the match length must be greater than zero
      -  ``newline_cr`` – Newlines for $, ^, and . are \\r.
      -  ``newline_lf`` – Newlines for $, ^, and . are \\n.
      -  ``newline_crlf`` – Newlines for $, ^, and . are \\r\n.
      -  ``newline_any`` – Newlines for $, ^, and . are any.

      Note that a regex created using ``all`` or ``partial`` will return an error.

   -  ``max``: **number** The maximum number of elements to return. If unspecified or less than 1, all elements are returned.

   .. rubric:: Returns:
      :name: returns-155

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **boolean** ,...}

   The elements separated by the regular expression. Each element is separated by any capture strings from the separator, if present. If a capture does not exist, false is returned for that capture. If there are no captures, only the elements are returned. For example:

   ::

       rx = glib.regex_new('\\|(.?)\\|')
       spl = rx:split('abc||def|!|ghi')
        -- { 'abc', '', 'def', '!', 'ghi' }


 .. _`regex:gsub`:

 **regex:gsub (s, repl[, start[, n[, mflags]]])**
   Replace occurrences of regular expression in string.

   .. rubric:: Parameters:
      :name: parameters-141

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to modify. Note that zeroes are not supported in the final result string, whether they stem from *s* or *repl*.

   -  ``repl``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ `table <http://www.lua.org/manual/5.1/manual.html#5.5>`__ \|\ **function** The replacement. If this is a string, the string is the replacement text, which supports backslash-escapes for capture substitution and case conversion. If it is a table, the first capture (or entire match if there are no captures, or false if the capture exists but is not matched) is used as a key into the table; if the value is a string or
      number, it is the literal replacement text; otherwise, if the value is false or ``nil``, no substitution is made. If it is a function, the function is called for every match, with all captures (or the entire match if there are no captures) as arguments (as with `regex:match`_                 , captures which do not exist are passed as false); the return value is treated like the table entries. For literal interpretation of a string, call `regex_escape_string`_                         on it
      first.

   -  ``start``: **number** The start position.

   -  ``n``: **number** \|\ **function** The maximum number of replacements, if specified as a number greater than 0. If specified as a function, the function is called after determining the potential replacement text. Its parameters are the full match start position, the full match end position, and the potential replacement text (or false/``nil`` if no replacement is to be made). The function must return two values: the first is the replacement operation: true if normal replacement is to be
      made, false if no replacement is to be made, and a string if an alternate replacement is to be made. The second is the conintuation flag: if absent, ``nil``, or false, continue replacement, and if true, continue globally without checking *n*, and if a number, continue that many iterations maximum without checking *n*.

   -  ``mflags``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...} Additional match flags:

      -  ``anchored`` – pattern must match at start of string
      -  ``notbol`` – ^ does not match the start of string (but \\A does)
      -  ``noteol`` – $ does not match the end of string (but \\Z does)
      -  ``notempty`` – the match length must be greater than zero
      -  ``newline_cr`` – Newlines for $, ^, and . are \\r.
      -  ``newline_lf`` – Newlines for $, ^, and . are \\n.
      -  ``newline_crlf`` – Newlines for $, ^, and . are \\r\n.
      -  ``newline_any`` – Newlines for $, ^, and . are any.

      Note that a regex created using ``all`` or ``partial`` will return an error.

   .. rubric:: Returns:
      :name: returns-156

   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The substituted string
   #. **number** The number of matches
   #. **number** The number of substitutions

   .. rubric:: Raises:
      :name: raises-66

   Returns ``nil`` and error message string on error.

   .. rubric:: see also:
      :name: see-also-46

   `regex_escape_string`_                        

_`Simple XML Subset Parser`
---------------------------

The following functions use varargs, and are not supported:

``g_markup_*printf_escaped()``: emulate using string concat and renaming of escaper to shorter name:

::

    e = glib.markup_escape_text
    output = '<purchase>' ..
             '<store>' .. e(store) .. '</store>' ..
             '<item>' .. e(item) .. '</item>' ..
             '</purchase>'

``g_markup_collect_attributes()``: the only useful bit here that is for some reason not exposed independently is the boolean parser. Otherwise, it's best to emulate using lua:

::

   -- usage:
   attrs, msg = collect_attrs(attr_names, attr_vals,
                              {a='str', b='bool', c='?bool', ...})
   if not attrs then print("error: " .. msg) end

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

..


 .. _`markup_escape_text`:

 **markup_escape_text (s)**
   Escape text so GMarkup XML parsing will return it to original.

   .. rubric:: Parameters:
      :name: parameters-142

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The string to escape

   .. rubric:: Returns:
      :name: returns-157

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The escaped string


 .. _`\_gmarkup_start_element_`:

 **\_gmarkup_start_element_ (ctx, name, attr_names, attr_values)**
   The function called when an opening tag of an element is seen.

   .. rubric:: Parameters:
      :name: parameters-143

   -  ``ctx``: `markup_parse_context`_                                The context in which this was called
   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name of the element being started
   -  ``attr_names``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...} The names of the attributes in this tag, in order
   -  ``attr_values``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...} The values of the attributes in this tag, in the same order as the names.

   .. rubric:: Usage:
      :name: usage-8

   ::

      function counter()
        local count = 0
        return {
          start_element = function() count = count + 1 end,
          pop = function() return count end
        }
      end
      gmp = markup_parse_context_new {
         start_element = function(ctx, el, ...)
           if el == 'count' return counter() end
         end,
         end_element = function(ctx, n, pop)
           if pop then print(pop()) end
         end
      }

   .. rubric:: Returns:
      :name: returns-158

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ =\ **value** ,...}\|\ **nil**

   If present and a table, push the parser context and use the returned parser instead. The current parser will resume upon reaching the associated end element. See `markup_parse_context_new`_                              for details.

   -  **start_element**: a function like `\_gmarkup_start_element\_`_                             .
   -  **end_element**: a function like `\_gmarkup_end_element\_`_                           .
   -  **text**: a function like `\_gmarkup_text\_`_                    .
   -  **passthrough**: a function like `\_gmarkup_passthrough\_`_                           .
   -  **error**: a function like `\_gmarkup_error\_`_                     .
   -  **pop**: a value to pass to the *end_element* handler when finished. It may be any value, but a function is probably most suitable. There is no guarantee that this value will ever be used, since it requires that no errors occur and that the *end_element* handler actually uses it.

   .. rubric:: Raises:
      :name: raises-67

   Returns error message string on error.

   .. rubric:: see also:
      :name: see-also-47

   -  `markup_parse_context_new`_                             
   -  `\_gmarkup_end_element\_`_                          
   -  `\_gmarkup_text\_`_                   
   -  `\_gmarkup_passthrough\_`_                          
   -  `\_gmarkup_error\_`_                    


 .. _`\_gmarkup_end_element_`:

 **\_gmarkup_end_element_ (ctx, name[, pop])**
   The function called when an ending tag of an element is seen.

   .. rubric:: Parameters:
      :name: parameters-144

   -  ``ctx``: `markup_parse_context`_                                The context in which this was called
   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name of the element being started
   -  ``pop``: **any** If the context was previously pushed, and this is called for the terminating element of that context, this is the ``pop`` element which was pushed along with the parser.

   .. rubric:: Raises:
      :name: raises-68

   Returns error message string on error.

   .. rubric:: see also:
      :name: see-also-48

   `markup_parse_context_new`_                             


 .. _`\_gmarkup_text_`:

 **\_gmarkup_text_ (ctx, text)**
   The function called when text within an element is seen.

   .. rubric:: Parameters:
      :name: parameters-145

   -  ``ctx``: `markup_parse_context`_                                The context in which this was called
   -  ``text``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The text.

   .. rubric:: Raises:
      :name: raises-69

   Returns error message string on error.

   .. rubric:: see also:
      :name: see-also-49

   `markup_parse_context_new`_                             


 .. _`\_gmarkup_passthrough_`:

 **\_gmarkup_passthrough_ (ctx, text)**
   The function called when unprocessed text is seen.

   .. rubric:: Parameters:
      :name: parameters-146

   -  ``ctx``: `markup_parse_context`_                                The context in which this was called
   -  ``text``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The text.

   .. rubric:: Raises:
      :name: raises-70

   Returns error message string on error.

   .. rubric:: see also:
      :name: see-also-50

   `markup_parse_context_new`_                             


 .. _`\_gmarkup_error_`:

 **\_gmarkup_error_ (ctx, text)**
   The function called when an error occurs during parsing.

   .. rubric:: Parameters:
      :name: parameters-147

   -  ``ctx``: `markup_parse_context`_                                The context in which this was called
   -  ``text``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The error text.

   .. rubric:: see also:
      :name: see-also-51

   `markup_parse_context_new`_                             


 .. _`markup_parse_context_new`:

 **markup_parse_context_new (options)**
   Create GMarkup parser.

   .. rubric:: Parameters:
      :name: parameters-148

   -  ``options``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ =\ **value** ,...}

      Context creation options:

      -  **start_element**: a function like `\_gmarkup_start_element\_`_                             .
      -  **end_element**: a function like `\_gmarkup_end_element\_`_                           .
      -  **text**: a function like `\_gmarkup_text\_`_                    .
      -  **passthrough**: a function like `\_gmarkup_passthrough\_`_                           .
      -  **error**: a function like `\_gmarkup_error\_`_                     .
      -  **treat_cdata_as_text**: If set and not false, return CDATA sections as text instead of passthrough.
      -  **prefix_error_position**: If set and not false, prefix error messages returned by the above functions with line and column information.

   .. rubric:: see also:
      :name: see-also-52

   -  `\_gmarkup_start_element\_`_                            
   -  `\_gmarkup_end_element\_`_                          
   -  `\_gmarkup_text\_`_                   
   -  `\_gmarkup_passthrough\_`_                          
   -  `\_gmarkup_error\_`_                    

Class _`markup_parse_context`
-----------------------------


 .. _`markup_parse_context:end_parse`:

 **markup_parse_context:end_parse ()**
   Finish parsing.

   .. rubric:: Returns:
      :name: returns-159

   **boolean** True

   .. rubric:: Raises:
      :name: raises-71

   Returns false and error message string on error.


 .. _`markup_parse_context:get_position`:

 **markup_parse_context:get_position ()**
   Obtain current position in source text.

   .. rubric:: Returns:
      :name: returns-160

   #. **number** The line number
   #. **number** The column number


 .. _`markup_parse_context:get_element`:

 **markup_parse_context:get_element ()**
   Obtain the name of the current element being processed.

   .. rubric:: Returns:
      :name: returns-161

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The element name.


 .. _`markup_parse_context:get_element_stack`:

 **markup_parse_context:get_element_stack ()**
   Obtain the complete path of element names to the current element being processed.

   .. rubric:: Returns:
      :name: returns-162

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}The element names, starting with the most deeply nested.


 .. _`markup_parse_context:parse`:

 **markup_parse_context:parse (s)**
   Parse some text.

   .. rubric:: Parameters:
      :name: parameters-149

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The next chunk of text to process

   .. rubric:: Returns:
      :name: returns-163

   **boolean** True

   .. rubric:: Raises:
      :name: raises-72

   Returns false and error message string on error.

_`Key-value file parser`
------------------------


 .. _`key_file_new`:

 **key_file_new ()**
   Create a new, empty key file.

   .. rubric:: Returns:
      :name: returns-164

   `key_file`_                    The empty key file

Class _`key_file`
-----------------


 .. _`key_file:set_list_separator`:

 **key_file:set_list_separator (sep)**
   Sets character to separate values in lists.

   .. rubric:: Parameters:
      :name: parameters-150

   -  ``sep``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The separator (only the first byte is used).


 .. _`key_file:load_from_file`:

 **key_file:load_from_file (f[, dirs[, keep_com[, keep_trans]]])**
   Load a file.

   .. rubric:: Parameters:
      :name: parameters-151

   -  ``f``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ File name
   -  ``dirs``: **boolean** \|{`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...} If true, search relative to standard configuration file directories. If a table, search realtive to all directories in the table. Otherwise, the file name is absolute or relative to the current directory.
   -  ``keep_com``: **boolean** If true, keep comments so they are written by `key_file:to_data`_                      .
   -  ``keep_trans``: **boolean** If true, keep all translations so they are written by `key_file:to_data`_                      .

   .. rubric:: Returns:
      :name: returns-165

   #. **boolean** True
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The actual file name if a directory search was done.

   .. rubric:: Raises:
      :name: raises-73

   Returns false and error message string on error.


 .. _`key_file:load_from_data`:

 **key_file:load_from_data (s[, keep_com[, keep_trans]])**
   Load data.

   .. rubric:: Parameters:
      :name: parameters-152

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The data
   -  ``keep_com``: **boolean** If true, keep comments so they are written by `key_file:to_data`_                      .
   -  ``keep_trans``: **boolean** If true, keep all translations so they are written by `key_file:to_data`_                      .

   .. rubric:: Returns:
      :name: returns-166

   **boolean** True

   .. rubric:: Raises:
      :name: raises-74

   Returns false and error message string on error.


 .. _`key_file:to_data`:

 **key_file:to_data ()**
   Convert entire key file to a string.

   .. rubric:: Returns:
      :name: returns-167

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key file contents

   .. rubric:: Raises:
      :name: raises-75

   Returns ``nil`` and error message string on error.


 .. _`key_file:save_to_file`:

 **key_file:save_to_file (name)**
   Writes out contents of key file. Uses same mechanism as `file_set`_              .

   This is only available with GLib 2.40 or later.

   .. rubric:: Parameters:
      :name: parameters-153

   -  ``name``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ File name

   .. rubric:: Returns:
      :name: returns-168

   **boolean** True if successful

   .. rubric:: Raises:
      :name: raises-76

   Returns false and error message string on error.


 .. _`key_file:get_start_group`:

 **key_file:get_start_group ()**
   Get the start group of the key file.

   .. rubric:: Returns:
      :name: returns-169

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name of the start group


 .. _`key_file:get_groups`:

 **key_file:get_groups ()**
   Get the names of all groups in the key file.

   .. rubric:: Returns:
      :name: returns-170

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}A table containing the names of all the groups.


 .. _`key_file:get_keys`:

 **key_file:get_keys (group)**
   Get the names of all keys in a group.

   .. rubric:: Parameters:
      :name: parameters-154

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The name of a group to query

   .. rubric:: Returns:
      :name: returns-171

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}A table containing the names of all keys in the \*group

   .. rubric:: Raises:
      :name: raises-77

   Returns ``nil`` and error message string on error.


 .. _`key_file:has_group`:

 **key_file:has_group (group)**
   Check if group exists.

   .. rubric:: Parameters:
      :name: parameters-155

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name

   .. rubric:: Returns:
      :name: returns-172

   **boolean** True if group exists in key file.


 .. _`key_file:has_key`:

 **key_file:has_key (group, key)**
   Check if key exists.

   .. rubric:: Parameters:
      :name: parameters-156

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key name

   .. rubric:: Returns:
      :name: returns-173

   **boolean** True if key exists in key file.

   .. rubric:: Raises:
      :name: raises-78

   Returns false and error message string on error.


 .. _`key_file:raw_get`:

 **key_file:raw_get (group, key)**
   Obtain raw value of a key.

   .. rubric:: Parameters:
      :name: parameters-157

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key name

   .. rubric:: Returns:
      :name: returns-174

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The value

   .. rubric:: Raises:
      :name: raises-79

   Returns ``nil`` and error message string on error.


 .. _`key_file:get`:

 **key_file:get (group, key[, locale])**
   Obtain value of a key.

   .. rubric:: Parameters:
      :name: parameters-158

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key
   -  ``locale``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ If specified, get value translated into this locale, if available

   .. rubric:: Returns:
      :name: returns-175

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The parsed UTF-8 value

   .. rubric:: Raises:
      :name: raises-80

   Returns ``nil`` and error message string on error.


 .. _`key_file:get_boolean`:

 **key_file:get_boolean (group, key)**
   Obtain value of a boolean key.

   .. rubric:: Parameters:
      :name: parameters-159

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key

   .. rubric:: Returns:
      :name: returns-176

   **boolean** The value

   .. rubric:: Raises:
      :name: raises-81

   Returns false and error message string on error.


 .. _`key_file:get_number`:

 **key_file:get_number (group, key)**
   Obtain value of a numeric key.

   .. rubric:: Parameters:
      :name: parameters-160

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key

   .. rubric:: Returns:
      :name: returns-177

   **number** The value

   .. rubric:: Raises:
      :name: raises-82

   Returns ``nil`` and error message string on error.


 .. _`key_file:get_list`:

 **key_file:get_list (group, key[, locale])**
   Obtain value of a string list key. Note that while `key_file:set_list`_                       escapes characters such as separators, this function does not handle such escapes correctly. It would be better to just use `key_file:raw_get`_                      and parse the list out manually if escaped characters might be present.

   .. rubric:: Parameters:
      :name: parameters-161

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key
   -  ``locale``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ If specified, get value translated into this locale, if available

   .. rubric:: Returns:
      :name: returns-178

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}The list of parsed UTF-8 values

   .. rubric:: Raises:
      :name: raises-83

   Returns ``nil`` and error message string on error.


 .. _`key_file:get_boolean_list`:

 **key_file:get_boolean_list (group, key)**
   Obtain value of a boolean list key.

   .. rubric:: Parameters:
      :name: parameters-162

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key

   .. rubric:: Returns:
      :name: returns-179

   {**boolean** ,...}The list of values

   .. rubric:: Raises:
      :name: raises-84

   Returns ``nil`` and error message string on error.


 .. _`key_file:get_number_list`:

 **key_file:get_number_list (group, key)**
   Obtain value of a number list key.

   .. rubric:: Parameters:
      :name: parameters-163

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key

   .. rubric:: Returns:
      :name: returns-180

   {**number** ,...}The list of values

   .. rubric:: Raises:
      :name: raises-85

   Returns ``nil`` and error message string on error.


 .. _`key_file:get_comment`:

 **key_file:get_comment ([group[, key]])**
   Obtain comment above a key or group.

   .. rubric:: Parameters:
      :name: parameters-164

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name; if unspecified, the first group is used, and *key* is ignored.
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key name; if specified, obtain comment above the key; otherwise, obtain comment above group

   .. rubric:: Returns:
      :name: returns-181

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|The comment string

   .. rubric:: Raises:
      :name: raises-86

   Returns ``nil`` and error message string on error.


 .. _`key_file:raw_set`:

 **key_file:raw_set (group, key, value)**
   Set raw value of a key.

   .. rubric:: Parameters:
      :name: parameters-165

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key name
   -  ``value``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The value


 .. _`key_file:set`:

 **key_file:set (group, key, value[, locale])**
   Set value of a key.

   .. rubric:: Parameters:
      :name: parameters-166

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key
   -  ``value``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The value
   -  ``locale``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **boolean** If a string, set value translated into this locale. Otherwise, if true, set value translated into current locale.


 .. _`key_file:set_boolean`:

 **key_file:set_boolean (group, key, value)**
   Set value of a boolean key.

   .. rubric:: Parameters:
      :name: parameters-167

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key
   -  ``value``: **boolean** The value


 .. _`key_file:set_number`:

 **key_file:set_number (group, key, value)**
   Set value of a numeric key.

   .. rubric:: Parameters:
      :name: parameters-168

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key
   -  ``value``: **number** The value


 .. _`key_file:set_list`:

 **key_file:set_list (group, key, value[, locale])**
   Set value of a string list key.

   .. rubric:: Parameters:
      :name: parameters-169

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key
   -  ``value``: {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...} The value
   -  ``locale``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ \|\ **boolean** If a string, set value translated into this locale. Otherwise, if true, set value translated into current locale.


 .. _`key_file:set_boolean_list`:

 **key_file:set_boolean_list (group, key, value)**
   Set value of a boolean list key.

   .. rubric:: Parameters:
      :name: parameters-170

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key
   -  ``value``: {**boolean** ,...} The value


 .. _`key_file:set_number_list`:

 **key_file:set_number_list (group, key)**
   Set value of a number list key.

   .. rubric:: Parameters:
      :name: parameters-171

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key


 .. _`key_file:set_comment`:

 **key_file:set_comment (comment[, group[, key]])**
   Set comment above a key or group.

   .. rubric:: Parameters:
      :name: parameters-172

   -  ``comment``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The comment
   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name; if unspecified, the first group is used, and *key* is ignored.
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key name; if specified, obtain comment above the key; otherwise, obtain comment above group

   .. rubric:: Returns:
      :name: returns-182

   **boolean** True

   .. rubric:: Raises:
      :name: raises-87

   Returns false and error message string on error.


 .. _`key_file:remove`:

 **key_file:remove (group[, key])**
   Remove a group or key.

   .. rubric:: Parameters:
      :name: parameters-173

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key. If specified, remove that key. Otherwise, remove the group *group*.

   .. rubric:: Returns:
      :name: returns-183

   **boolean** True

   .. rubric:: Raises:
      :name: raises-88

   Returns false and error message string on error.


 .. _`key_file:remove_comment`:

 **key_file:remove_comment ([group[, key]])**
   Remove comment above a key or group.

   .. rubric:: Parameters:
      :name: parameters-174

   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group name; if unspecified, the first group is used, and *key* is ignored.
   -  ``key``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The key name; if specified, obtain comment above the key; otherwise, obtain comment above group

   .. rubric:: Returns:
      :name: returns-184

   **boolean** True

   .. rubric:: Raises:
      :name: raises-89

   Returns false and error message string on error.

_`Bookmark file parser`
-----------------------


 .. _`bookmark_file_new`:

 **bookmark_file_new ()**
   Create a new, empty bookmark file.

   .. rubric:: Returns:
      :name: returns-185

   `bookmark_file`_                         The empty bookmark file.

Class _`bookmark_file`
----------------------


 .. _`bookmark_file:load_from_file`:

 **bookmark_file:load_from_file (f[, use_dirs])**
   Load a file.

   .. rubric:: Parameters:
      :name: parameters-175

   -  ``f``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ File name
   -  ``use_dirs``: **boolean** If true, search relative to standard configuration file directories.

   .. rubric:: Returns:
      :name: returns-186

   #. **boolean** True
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The actual file name if a directory search was done.

   .. rubric:: Raises:
      :name: raises-90

   Returns false and error message string on error.


 .. _`bookmark_file:load_from_data`:

 **bookmark_file:load_from_data (s)**
   Load data.

   .. rubric:: Parameters:
      :name: parameters-176

   -  ``s``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The data

   .. rubric:: Returns:
      :name: returns-187

   **boolean** True

   .. rubric:: Raises:
      :name: raises-91

   Returns false and error message string on error.


 .. _`bookmark_file:to_data`:

 **bookmark_file:to_data ()**
   Convert bookmark file to a string.

   .. rubric:: Returns:
      :name: returns-188

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The bookmark file contents

   .. rubric:: Raises:
      :name: raises-92

   Returns ``nil`` and error message string on error.


 .. _`bookmark_file:to_file`:

 **bookmark_file:to_file (f)**
   Write bookmark file to a file.

   .. rubric:: Parameters:
      :name: parameters-177

   -  ``f``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The file name

   .. rubric:: Returns:
      :name: returns-189

   **boolean** True

   .. rubric:: Raises:
      :name: raises-93

   Returns false and error message string on error.


 .. _`bookmark_file:has_item`:

 **bookmark_file:has_item (uri)**
   Check if bookmark file has given URI.

   .. rubric:: Parameters:
      :name: parameters-178

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI to find

   .. rubric:: Returns:
      :name: returns-190

   **boolean** True if present


 .. _`bookmark_file:has_group`:

 **bookmark_file:has_group (uri, group)**
   Check if bookmark file has given URI in a given group.

   .. rubric:: Parameters:
      :name: parameters-179

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI to find
   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group to find

   .. rubric:: Returns:
      :name: returns-191

   **boolean** True if present in group

   .. rubric:: Raises:
      :name: raises-94

   Returns false and error message string on error.


 .. _`bookmark_file:has_application`:

 **bookmark_file:has_application (uri, app)**
   Check if bookmark file has given URI registered by a given application.

   .. rubric:: Parameters:
      :name: parameters-180

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI to find
   -  ``app``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The application

   .. rubric:: Returns:
      :name: returns-192

   **boolean** True if registed by application


 .. _`bookmark_file:__len`:

 **bookmark_file:__len ()**
   Get the number of bookmarks. This is the standard Lua # operator, applied to a bookmark file.

   .. rubric:: Returns:
      :name: returns-193

   **number** The number of bookmarks.


 .. _`bookmark_file:uris`:

 **bookmark_file:uris ()**
   Get all URIs.

   .. rubric:: Returns:
      :name: returns-194

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}All URIs.


 .. _`bookmark_file:title`:

 **bookmark_file:title (uri)**
   Get title for URI

   .. rubric:: Parameters:
      :name: parameters-181

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-195

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Its title

   .. rubric:: Raises:
      :name: raises-95

   Returns ``nil`` and error message string on error.


 .. _`bookmark_file:description`:

 **bookmark_file:description (uri)**
   Get description for URI

   .. rubric:: Parameters:
      :name: parameters-182

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-196

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Its description

   .. rubric:: Raises:
      :name: raises-96

   Returns ``nil`` and error message string on error.


 .. _`bookmark_file:mime_type`:

 **bookmark_file:mime_type (uri)**
   Get MIME type for URI

   .. rubric:: Parameters:
      :name: parameters-183

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-197

   `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Its MIME type

   .. rubric:: Raises:
      :name: raises-97

   Returns ``nil`` and error message string on error.


 .. _`bookmark_file:is_private`:

 **bookmark_file:is_private (uri)**
   Get private flag for URI

   .. rubric:: Parameters:
      :name: parameters-184

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-198

   **boolean** True if private flag set

   .. rubric:: Raises:
      :name: raises-98

   Returns false and error message string on error.


 .. _`bookmark_file:icon`:

 **bookmark_file:icon (uri)**
   Get icon for URI.

   .. rubric:: Parameters:
      :name: parameters-185

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-199

   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The icon URL
   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The icon's MIME type

   .. rubric:: Raises:
      :name: raises-99

   Returns ``nil`` and error message string on error.


 .. _`bookmark_file:added`:

 **bookmark_file:added (uri)**
   Get time URI was added.

   .. rubric:: Parameters:
      :name: parameters-186

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-200

   **number** The time stamp, as seconds from epoch

   .. rubric:: Raises:
      :name: raises-100

   Returns ``nil`` and error message string on error.


 .. _`bookmark_file:modified`:

 **bookmark_file:modified (uri)**
   Get time URI was last modified.

   .. rubric:: Parameters:
      :name: parameters-187

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-201

   **number** The time stamp, as seconds from epoch

   .. rubric:: Raises:
      :name: raises-101

   Returns ``nil`` and error message string on error.


 .. _`bookmark_file:visited`:

 **bookmark_file:visited (uri)**
   Get time URI was last visited.

   .. rubric:: Parameters:
      :name: parameters-188

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-202

   **number** The time stamp, as seconds from epoch

   .. rubric:: Raises:
      :name: raises-102

   Returns ``nil`` and error message string on error.


 .. _`bookmark_file:groups`:

 **bookmark_file:groups (uri)**
   Get list of groups to which URI belongs.

   .. rubric:: Parameters:
      :name: parameters-189

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-203

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}The list of groups

   .. rubric:: Raises:
      :name: raises-103

   Returns ``nil`` and error message string on error.


 .. _`bookmark_file:applications`:

 **bookmark_file:applications (uri)**
   Get list of applications which registered this URI.

   .. rubric:: Parameters:
      :name: parameters-190

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-204

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}The list of applications

   .. rubric:: Raises:
      :name: raises-104

   Returns ``nil`` and error message string on error.


 .. _`bookmark_file:boomark_file:app_info`:

 **bookmark_file:boomark_file:app_info (uri, app)**
   Obtain registration information for application which registered URI.

   .. rubric:: Parameters:
      :name: parameters-191

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``app``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Application name

   .. rubric:: Returns:
      :name: returns-205

   #. `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The command to invoke *app* on *uri*
   #. **number** The number of times *app* registered *uri*
   #. **number** The last time *app* registered *uri*

   .. rubric:: Raises:
      :name: raises-105

   Returns ``nil`` and error message string on error.


 .. _`bookmark_file:set_title`:

 **bookmark_file:set_title ([uri], title)**
   Set title for URI

   .. rubric:: Parameters:
      :name: parameters-192

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI. If ``nil``, the title of the bookmark file is set.
   -  ``title``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The new title


 .. _`bookmark_file:set_description`:

 **bookmark_file:set_description ([uri], desc)**
   Set description for URI

   .. rubric:: Parameters:
      :name: parameters-193

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI. If ``nil``, the title of the bookmark file is set.
   -  ``desc``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The new description


 .. _`bookmark_file:set_mime_type`:

 **bookmark_file:set_mime_type (uri, mime_type)**
   Set MIME type for URI

   .. rubric:: Parameters:
      :name: parameters-194

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``mime_type``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The new MIME type


 .. _`bookmark_file:set_is_private`:

 **bookmark_file:set_is_private (uri, private)**
   Set private flag for URI

   .. rubric:: Parameters:
      :name: parameters-195

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``private``: **boolean** The new flag


 .. _`bookmark_file:set_icon`:

 **bookmark_file:set_icon (uri, icon, mime_type)**
   Set icon for URI.

   .. rubric:: Parameters:
      :name: parameters-196

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``icon``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The icon URL
   -  ``mime_type``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The icon's MIME type


 .. _`bookmark_file:set_added`:

 **bookmark_file:set_added (uri, time)**
   Set time URI was added.

   .. rubric:: Parameters:
      :name: parameters-197

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``time``: **number** The time stamp, as seconds from epoch


 .. _`bookmark_file:set_modified`:

 **bookmark_file:set_modified (uri, time)**
   Set time URI was modified.

   .. rubric:: Parameters:
      :name: parameters-198

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``time``: **number** The time stamp, as seconds from epoch


 .. _`bookmark_file:set_visited`:

 **bookmark_file:set_visited (uri, time)**
   Set time URI was visited.

   .. rubric:: Parameters:
      :name: parameters-199

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``time``: **number** The time stamp, as seconds from epoch


 .. _`bookmark_file:set_groups`:

 **bookmark_file:set_groups (uri)**
   Set list of groups to which URI belongs.

   .. rubric:: Parameters:
      :name: parameters-200

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-206

   {`string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ ,...}The list of groups


 .. _`bookmark_file:set_app_info`:

 **bookmark_file:set_app_info (uri, app, exec[, rcount[, stamp]])**
   Set registration information for application which registered URI.

   .. rubric:: Parameters:
      :name: parameters-201

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``app``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ Application name
   -  ``exec``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The command to invoke *app* on *uri* (%f == file, %u == uri)
   -  ``rcount``: **number** The number of times *app* registered *uri* (absent, ``nil``, or less than 0 to simply increment, or 0 to remove)
   -  ``stamp``: **number** The last time *app* registered *uri* (or -1, ``nil``, or absent for current time)

   .. rubric:: Returns:
      :name: returns-207

   **boolean** True

   .. rubric:: Raises:
      :name: raises-106

   Returns false and error message string on error.


 .. _`bookmark_file:add_group`:

 **bookmark_file:add_group (uri, group)**
   Add a group to the list of groups URI belongs to.

   .. rubric:: Parameters:
      :name: parameters-202

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group


 .. _`bookmark_file:add_application`:

 **bookmark_file:add_application (uri, app, exec)**
   Add an application to the list of applications that registered this URI.

   .. rubric:: Parameters:
      :name: parameters-203

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``app``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The application name
   -  ``exec``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The command line to invoke application on URI (%f = file, %u = URI)


 .. _`bookmark_file:remove_group`:

 **bookmark_file:remove_group (uri, group)**
   Remove a group from the list of groups URI belongs to.

   .. rubric:: Parameters:
      :name: parameters-204

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``group``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The group

   .. rubric:: Returns:
      :name: returns-208

   **boolean** True

   .. rubric:: Raises:
      :name: raises-107

   Returns false and error message string on error.


 .. _`bookmark_file:remove_application`:

 **bookmark_file:remove_application (uri, app)**
   Remove an application from the list of applications that registered this URI.

   .. rubric:: Parameters:
      :name: parameters-205

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``app``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The application name

   .. rubric:: Returns:
      :name: returns-209

   **boolean** True

   .. rubric:: Raises:
      :name: raises-108

   Returns false and error message string on error.


 .. _`bookmark_file:remove`:

 **bookmark_file:remove (uri)**
   Remove URI.

   .. rubric:: Parameters:
      :name: parameters-206

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI

   .. rubric:: Returns:
      :name: returns-210

   **boolean** True

   .. rubric:: Raises:
      :name: raises-109

   Returns false and error message string on error.


 .. _`bookmark_file:move`:

 **bookmark_file:move (uri, new)**
   Change URI, retaining group and application information.

   .. rubric:: Parameters:
      :name: parameters-207

   -  ``uri``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The URI
   -  ``new``: `string <http://www.lua.org/manual/5.1/manual.html#5.4>`__ The new URI

   .. rubric:: Returns:
      :name: returns-211

   **boolean** True

   .. rubric:: Raises:
      :name: raises-110

   Returns false and error message string on error.

*generated by* `LDoc 1.2 <http://github.com/stevedonovan/LDoc>`__
