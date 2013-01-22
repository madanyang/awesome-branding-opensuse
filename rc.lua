--  rc.lua
--  custom initialization for awesome windowmanager 3.4.13
--
 -- Copyright (C) 2012, 2013 by Togan Muftuoglu toganm@opensuse.org
 -- This program is free software; you can redistribute it and/or
 -- modify it under the terms of the GNU General Public License as
 -- published by the Free Software Foundation; either version 2, or (at
 -- your option) any later version.

 -- This program is distributed in the hope that it will be useful, but
 -- WITHOUT ANY WARRANTY; without even the implied warranty of
 -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 -- General Public License for more details.

 -- You should have received a copy of the GNU General Public License
 -- along with GNU Emacs; see the file COPYING.  If not, write to the
 -- Free Software Foundation, Inc.,  51 Franklin Street, Fifth Floor,
 -- Boston, MA 02110-1301 USA


-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Freedesktop integration
-- FIXME for 3,5 since freedesktop is not compatabible
require("freedesktop.utils")
freedesktop.menu = require("freedesktop.menu")
freedesktop.desktop = require("freedesktop.desktop")
-- use local keyword for awesome 3.5 compatability
-- calendar functions
local calendar2 = require("calendar2")
-- Extra widgets
local vicious = require("vicious")
-- to create shortcuts help screen
local keydoc = require("keydoc")
-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/openSUSE/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "xterm"
editor = os.getenv("EDITOR") or os.getenv("VISUAL") or "vi"
editor_cmd = terminal .. " -e " .. editor

freedesktop.utils.terminal = terminal
freedesktop.utils.icon_theme = 'gnome'

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}


-- {{{ Menu
-- Create a laucher widget and a main menu

  mysystem_menu = {
      { 'Lock Screen',     'xscreensaver-command -lock', freedesktop.utils.lookup_icon({ icon = 'system-lock-screen'        }) },
      { 'Logout',           awesome.quit,                freedesktop.utils.lookup_icon({ icon = 'system-log-out'            }) },
      { 'Reboot System',   'xdg-su -c "shutdown -r now"',   freedesktop.utils.lookup_icon({ icon = 'reboot-notifier'           }) },
      { 'Shutdown System', 'xdg-su -c "shutdown -h now"',   freedesktop.utils.lookup_icon({ icon = 'system-shutdown'           }) }
   }

  myawesome_menu = {
     { 'Restart Awesome', awesome.restart,              freedesktop.utils.lookup_icon({ icon = 'gtk-refresh'               }) },
     { "Edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
     { "manual", terminal .. " -e man awesome" }
  }

top_menu = {
      { 'Applications', freedesktop.menu.new(),          freedesktop.utils.lookup_icon({ icon = 'start-here'                }) },
      { 'Awesome',      myawesome_menu,                    beautiful.awesome_icon },
      { 'System',       mysystem_menu,                     freedesktop.utils.lookup_icon({ icon = 'system'                    }) },
      { 'Terminal',     freedesktop.utils.terminal,      freedesktop.utils.lookup_icon({ icon = 'terminal'                  }) }
   }

mymainmenu = awful.menu.new({ items = top_menu, width = 150 })


mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon), menu = mymainmenu })
-- }}}

   -- desktop icons
   for s = 1, screen.count() do
      freedesktop.desktop.add_applications_icons({screen = s, showlabels = true})
      freedesktop.desktop.add_dirs_and_files_icons({screen = s, showlabels = true})
   end



-- {{{ Wibox
-- We need spacer and separator between the widgets
spacer = widget({type = "textbox"})
separator = widget({type = "textbox"})
spacer.text = " "
separator.text = "|"


-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

calendar2.addCalendarToWidget(mytextclock, "<span color='green'>%s</span>")


mycpuwidget = widget({ type = "textbox" })
vicious.register(mycpuwidget, vicious.widgets.cpu, "$1%")

mybattery = widget({ type = "textbox"})
vicious.register(mybattery, function(format, warg)
  local args = vicious.widgets.bat(format, warg)
  if args[2] < 50 then
    args['{color}'] = 'red'
  else
    args['{color}'] = 'green'
  end
  return args
end, '<span foreground="${color}">bat: $2% $3%</span>', 10, 'BAT0')

-- Initialize widget
mynetwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(mynetwidget, vicious.widgets.net, "${eth0 down_kb} / ${eth0 up_kb}", 1)

-- wifi
-- provides wireless information for a requested interface
-- takes the network interface as an argument, i.e. "wlan0"
-- returns a table with string keys: {ssid}, {mode}, {chan}, {rate}, {link}, {linp} and {sign}

-- Weather widget
myweatherwidget = widget({ type = "textbox" })
weather_t = awful.tooltip({ objects = { myweatherwidget },})
vicious.register(myweatherwidget, vicious.widgets.weather,
                function (widget, args)
                    weather_t:set_text("City: " .. args["{city}"] .."\nWind: " .. args["{windkmh}"] .. "km/h " .. args["{wind}"] .. "\nSky: " .. args["{sky}"] .. "\nHumidity: " .. args["{humid}"] .. "%")
                    return args["{tempc}"] .. "C"
                end, 1800, "EDDN")
                --'1800': check every 30 minutes.
                --'EDDN': Nuermberg ICAO code.


-- Keyboard map indicator and changer
-- https://awesome.naquadah.org/wiki/Change_keyboard_maps
-- default keyboard is us, second is german adapt to your needs
--

    kbdcfg = {}
    kbdcfg.cmd = "setxkbmap"
    kbdcfg.layout = { { "us", "" }, { "de", "" } }
    kbdcfg.current = 1  -- us is our default layout
    kbdcfg.widget = widget({ type = "textbox", align = "right" })
    kbdcfg.widget.text = " " .. kbdcfg.layout[kbdcfg.current][1] .. " "
    kbdcfg.switch = function ()
       kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
       local t = kbdcfg.layout[kbdcfg.current]
       kbdcfg.widget.text = " " .. t[1] .. " "
       os.execute( kbdcfg.cmd .. " " .. t[1] .. " " .. t[2] )
    end

    -- Mouse bindings
    kbdcfg.widget:buttons(awful.util.table.join(
        awful.button({ }, 1, function () kbdcfg.switch() end)
    ))

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],

        mytextclock,
        separator,
        spacer,

        kbdcfg.widget,
        spacer,
        separator,
        spacer,

        mycpuwidget,
        spacer,
        separator,
        spacer,

        mybattery,
        spacer,
        separator,
        spacer,

        mynetwidget,
        spacer,
        separator,
        spacer,

        myweatherwidget,
        spacer,
        separator,
        spacer,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- these are needed by the keydoc a better solution would be to place them in theme.lua
-- but leaving them here also provides a mean to change the colors here ;)

   beautiful.fg_widget_value="green"
   beautiful.fg_widget_clock="gold"
   beautiful.fg_widget_value_important="red"



-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
   keydoc.group("Global Keys"),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,"Previous Tag" ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,"Next tag" ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,"Clear Choice"),
    awful.key({modkey,}, "F1",keydoc.display,"Display Keymap Menu"),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end,"Raise focus"),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end,"Lower focus"),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end,"Show menu"),

    -- Layout manipulation
    keydoc.group("Layout manipulation"),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,"Swap with next window"),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,"Swap with previous window "),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,"Relative focus increase" ),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,"Relative focus decrease"),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,"Jump to window "),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,"Cycle windows or windows style"),

    -- Standard program
    keydoc.group("Standard Programs"),
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end,"Open terminal"),
    awful.key({ modkey, "Control" }, "r", awesome.restart,"Restart awesome"),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,"Quit awesome"),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end,"Increase window size"),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end,"Decrease window size"),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end,"Increase master"),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end,"Decrease master"),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end,"Increase column"),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end,"Decrease column"),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end,"Cycle layout style forward"),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end,"Cycle layout style reverse"),

    awful.key({ modkey, "Control" }, "n", awful.client.restore,"Client restore"),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end,"Run command"),
    -- this function below will enable ssh login as long as the remote host is defined in $HOME/.ssh/config
    -- else by give the remote host name at the prompt which will also work
    awful.key({ modkey,           }, "s",
              function ()
                  awful.prompt.run({ prompt = "ssh: " },
                  mypromptbox[mouse.screen].widget,
                  function(h) awful.util.spawn(terminal .. " -e slogin " .. h) end,
                  function(cmd, cur_pos, ncomp)
                      -- get hosts and hostnames
                      local hosts = {}
                      f = io.popen("sed 's/#.*//;/[ \\t]*Host\\(Name\\)\\?[ \\t]\\+/!d;s///;/[*?]/d' " .. os.getenv("HOME") .. "/.ssh/config | sort")
                      for host in f:lines() do
                          table.insert(hosts, host)
                      end
                      f:close()
                      -- abort completion under certain circumstances
                      if cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " " then
                          return cmd, cur_pos
                      end
                      -- match
                      local matches = {}
                      table.foreach(hosts, function(x)
                          if hosts[x]:find("^" .. cmd:sub(1, cur_pos):gsub('[-]', '[-]')) then
                              table.insert(matches, hosts[x])
                          end
                      end)
                      -- if there are no matches
                      if #matches == 0 then
                          return cmd, cur_pos
                      end
                      -- cycle
                      while ncomp > #matches do
                          ncomp = ncomp - #matches
                      end
                      -- return match and position
                      return matches[ncomp], #matches[ncomp] + 1
                  end,
                  awful.util.getdir("cache") .. "/ssh_history")
              end,"SSH login"),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end,"Run lua command")
)

clientkeys = awful.util.table.join(
   keydoc.group("Window management"),
   awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end,"Toggle fullscreen"),
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,"Kill window"),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,"Toggle floating"    ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,"Swap to master"),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen,"Move to screen" ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw() end,"redraw window"),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,"Minimize client"),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end,"Maximize client")
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    -- to fix youtube fullscreen problems if still seeing bottom bar
    -- for chromium change "plugin-container" to "exe"

    { rule = { instance = "plugin-container" },
      properties = { floating = true } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
