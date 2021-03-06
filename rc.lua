--Стандартный библиотеки
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
--Библиотеки виджетов и лайоутов
local wibox = require("wibox")
--Настройки тем
local beautiful = require("beautiful")
--Библиотеки для оповещения
naughty = require("naughty")
local menubar = require("menubar")

-- Управление звуком
--local APW = require("apw/widget")

local cal = require("utils.cal")

-- Тестирование Lain
--local lain = require("lain")

naughty.config.defaults.timeout          = 5
naughty.config.defaults.screen           = 1
naughty.config.defaults.position         = "top_right"
naughty.config.defaults.margin           = 4
naughty.config.defaults.height           = 60
naughty.config.defaults.width            = 300
naughty.config.defaults.gap              = 1
naughty.config.defaults.ontop            = true
naughty.config.defaults.font             = beautiful.font or "Verdana 8"
naughty.config.defaults.icon             = nil
naughty.config.defaults.icon_size        = 16
naughty.config.defaults.fg               = beautiful.fg_focus or '#ffffff'
naughty.config.defaults.bg               = beautiful.bg_focus or '#535d6c'
naughty.config.presets.border_color     = beautiful.border_focus or '#000000'
naughty.config.defaults.border_width     = 1
naughty.config.defaults.hover_timeout    = nil

-->>Обработка ошибок
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Ой. Во время старта произошла ошибка!",
    text = awesome.startup_errors
  })
end

--Предоставление ошибки во время старта
do
  local in_error = false
  awesome.connect_signal("debug::error",
    function (err)
      -- Make sure we don't go into an endless error loop
      if in_error then return end
      in_error = true

      naughty.notify({
        preset = naughty.config.presets.critical,
        title = "А трабла то уже случилась!",
        text = err
      })
      in_error = false
    end)
end

-->>Переменные окружения
--Тема, цвета, шрифты и обои
--beautiful.init("/home/rb/.config/awesome/themes/zenburn/theme.lua")
beautiful.init(awful.util.getdir("config") .. "/themes/current_theme/theme.lua")
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")

--Локаль
os.setlocale("ru_RU.utf8")

--Пользовательские переменные
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
--config_dir = ("/home/rb/.config/awesome/")
--themes_dir = (config_dir .. "/themes")
--beautiful.init(themes_dir .. "/powerarrow/theme.lua")
config = {
  terminal = "urxvt"
}

--Обои
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
--<<

-->>Layouts && Tags
local layouts = {
  awful.layout.suit.floating,     -- 1
  awful.layout.suit.tile,         -- 2
  awful.layout.suit.tile.bottom,  -- 3
  awful.layout.suit.fair,         -- 4
  awful.layout.suit.max,          -- 5

  --lain.layout.termfair,           -- Делит на 3 ровные части
  --lain.layout.uselesstile,
  --lain.layout.centerfair,         -- По центру выравнивание до 3
  --lain.layout.cascade,
  --lain.layout.cascadetile,
  --lain.layout.centerwork,         -- Полный центр и рядом
  --lain.layout.uselessfair,
  --lain.layout.uselesspiral
}

tags = {}

do
  local float, tile, tileb, fair, max = layouts[1], layouts[2], layouts[3], layouts[4], layouts[5]
  for s = 1, screen.count() do
    tags[s] = awful.tag(
      { "[ Web ]", "[ MH ]", "[ Term ]", "[ Chat ]", "[ Mail ]", "[ Files ]", "[ Help ]" },
      s,
      {  max     , tile    , fair      , tile      , max       , tile       , float      }
    )
    --tags[s] = awful.tag({ "♨", "⌨", "⚡", "✉", "☕", "❁", "☃", "☄", "⚢" }, s, layouts[1])
    --tags[s] = awful.tag({ "➊", "➋", "➌", "➍", "➎", "➏", "➐", "➑", "➒"  }, s, layouts[1])
    --tags[s] = awful.tag({ "☭", "⌥", "✇", "⌤", "☼", "⌘","⍜", "✣","☕"  }, s, layouts[1])
    --tags[s] = awful.tag({ "  α  ", "  β  ", "  ζ  ", "  Θ  ", "  Ξ  ", "  ς  ", "  ψ  "  }, s, layouts[1])
    --tags[s] = awful.tag({ "⠐", "⠡", "⠪", "⠵", "⠻", "⠿" }, s, layouts[1])
    awful.tag.setncol(2, tags[s][4])
    awful.tag.setproperty(tags[s][4], "mwfact", 0.20)
  end
end
--<<

-->>Меню
internet_menu = {
  { "Firefox", firefox, beautiful.firefox_icon },
  { "GoogleChrome", google, beautiful.chrome_icon }
}

console_menu = {
  { "manual", terminal .. " -e man awesome" },
}

editors_menu = {
  { "Kate", "kate" },
  { "GVim", "gvim" },
}

system_menu = {
  { "Выйти", awesome.quit },
  { "Спящий режим" },
  { "Перезагрузка", function()  awful.util.spawn_with_shell("systemctl reboot") end, beautiful.reboot_icon},
  { "Выключение", function()  awful.util.spawn_with_shell("systemctl poweroff") end, beautiful.poweroff_icon}
}

mythememenu = {}
function theme_load(theme)
   local cfg_path = awful.util.getdir("config")
   -- Создание символической ссылки на выбраную тему в /home/user/.config/awesome/current_theme
   awful.util.spawn("ln -sfn " .. cfg_path .. "/themes/" .. theme .. " " .. cfg_path .. "/themes/current_theme")
   awesome.restart()
end

function theme_menu()
   -- Прочитать все файлы тем и добавить их в таблицу меню
   local cmd = "ls -1 " .. awful.util.getdir("config") .. "/themes/"
   local f = io.popen(cmd)

   for l in f:lines() do
    local item = { l, function () theme_load(l) end }
    table.insert(mythememenu, item)
   end

   f:close()
end
-- Создаем таблицу меню при запуске или перезапуске
theme_menu()


start_menu = awful.menu({
  items = {
    { "Manual", terminal .. " -e man awesome" },
    { "Internet", internet_menu },
    { "Editors", editors_menu },
    { "themes", mythememenu },
    { "Система", system_menu }
  }
})

--
function context_menu(c)
    if c.minimized then                               --меняем текст элемента меню в зависимости от состояния
         cli_min = "Развернуть"
    else
         cli_min = "Свернуть"
    end
    if c.ontop then
         cli_top = "★ Поверх всех"
     else
         cli_top = "  Поверх всех"
    end
    if awful.client.floating.get(c) then
         cli_float = "★ Floating"
     else
         cli_float = "  Floating"
     end
     --создаем список тегов(в виде подменю), для перемещения клиента на другой тег
     --tag_menu = { }
     --for i,t in pairs(tags.names) do
     --     if not tags[c.screen][i].selected then			--удаляем из списка выбранный тег/теги
     --         table.insert(tag_menu, { tostring(t), function() awful.client.movetotag(tags[c.screen][i]) end } )
     --     end
     --end
     taskmenu = awful.menu({ items = { --{ "Переместить на", tag_menu },
                                       { cli_min, function() c.minimized = not c.minimized end },
                                       { "Fullscreen", function() c.fullscreen = not c.fullscreen end, beautiful.layout_fullscreen },
                                       { cli_float,  function() awful.client.floating.toggle(c) end },
                                       { cli_top, function() c.ontop = not c.ontop end },
                                       { "Закрыть", function() c:kill() end },
                                     }
                           })
     taskmenu:show()
     return taskmenu
end
--

start_button = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = start_menu
})

menubar.utils.terminal = terminal
--<<

-->>Виджеты
--Переключатель клавиатуры
keyboard = wibox.widget.textbox(" Eng ")
keyboard.border_width = 1
keyboard.border_color = beautiful.fg_normal
keyboard:set_text(" Eng ")

keyboard_text = {
  [0] = " Eng ",
  [1] = " Рус "
}

dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.connect_signal("ru.gentoo.kbdd",
  function(...)
    local data = {...}
    local layout = data[2]
    keyboard:set_markup(keyboard_text[layout])
  end
)

--Часы и календарь
mytextclock = awful.widget.textclock(" %a %d %b, %H:%M ")
--calendar2.addCalendarToWidget(mytextclock, "<span color='green'>%s</span>")
cal.register(mytextclock, "<b><span color='red'>%s</span></b>")

--require('calendar2')
--calendar2.addCalendarToWidget(mytextclock)

--Разделители
split_line = wibox.widget.textbox()
split_line:set_markup("|")
split_tab = wibox.widget.textbox()
split_tab:set_markup("   ")
split_space = wibox.widget.textbox()
split_space:set_markup(" ")

--Батарейка
battery_widget = wibox.widget.textbox()

function battery_status ()
  local output={} --output buffer
  local fd=io.popen("acpi -b", "r") --list present batteries
  local line=fd:read()
  while line do --there might be several batteries.
    local battery_num = string.match(line, "Battery (%d+)")
    local battery_load = string.match(line, " (%d+)%%")
    local time_rem = string.match(line, "(%d+:%d+):%d+")
    local discharging
    local power
    if string.match(line, "Discharging")=="Discharging" then --discharging: always red
      discharging="<span color=\"#FF0000\"> ↓ </span>"
    else --charging
      discharging="<span color=\"#12CC2C\"> ↑ </span>"
    end
    
    if tonumber(battery_load)<9 then
      power="<span color=\"#EB373F\">"
      naughty.notify({title = "⚡ Beware! ⚡",
        text = "Battery charge is low ( ⚡ "..battery_load.." )!",
        timeout = 10,
        position = "top_right",
        fg = beautiful.fg_focus,
        bg = beautiful.bg_focus
      })
    elseif tonumber(battery_load)<30 then   
      power="<span color=\"#E8AA30\">"
    elseif tonumber(battery_load)<60 then
      power="<span color=\"#DFE20A\">"
    elseif tonumber(battery_load)<=100 then
      power="<span color=\"#18E818\">"
    end
    
    if battery_num and battery_load and time_rem then
      table.insert(output,discharging.."⚡ "..power..battery_load.."% "..time_rem.."</span>")
    elseif battery_num and battery_load then --remaining time unavailable
      table.insert(output,discharging.."⚡ "..power..battery_load.."%</span>")
    end --even more data unavailable: we might be getting an unexpected output format, so let's just skip this line.
    line=fd:read() --read next line
  end
  return table.concat(output,"/") --FIXME: better separation for several batteries. maybe a pipe?
end

battery_widget:set_markup(" " .. battery_status() .. " ")
battery_widget_timer = timer({ timeout = 30 })
battery_widget_timer:connect_signal("timeout", 
  function()
    battery_widget:set_markup(" " .. battery_status() .. " ")
  end)
battery_widget_timer:start()

-- Диск
fs_root = wibox.widget.textbox()
fs_root:set_text(" Занято: X% ")
fs_timer = timer ({timeout = 600}) --раз в 10 минут
fs_timer:connect_signal ("timeout", 
  function () 
    awful.util.spawn_with_shell("dbus-send --session --dest=org.naquadah.awesome.awful /ru/console/df ru.console.df.fsValue string:$(df -h --output='pcent' /home | sed '1d;s/ //g' )" ) 
  end)
fs_timer:start()
dbus.request_name("session", "ru.console.df")
dbus.add_match("session", "interface='ru.console.df', member='fsValue' " )
dbus.connect_signal("ru.console.df",
  function (...)
    local data = {...}
    local dbustext = data[2]
    fs_root:set_text(" Занято: " .. dbustext)
  end )

-- Translation text
function clip_translate()
  local clip = nil
  clip = awful.util.pread("xclip -o")
  if clip then
    awful.util.spawn("/home/rb/bin/google_translate.sh \"" .. clip .."\"",false)
  end
end

-- quake
local quake = require("quake")
local quakeconsole = {}

-->>Настройка панелей
--Именование клавиш миши
local maus = {
  LEFT = 1,
  MIDDLE = 2,
  RIGHT = 3,
  WHEEL_UP = 4,
  WHEEL_DOWN = 5
}

mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}

top_panel_box = {}
bottom_panel_box = {}

mytaglist.buttons = awful.util.table.join(
  awful.button({ }, maus.LEFT, awful.tag.viewonly),
  awful.button({ modkey }, maus.LEFT, awful.client.movetotag),
  awful.button({ }, maus.RIGHT, awful.tag.viewtoggle),
  awful.button({ modkey }, maus.RIGHT, awful.client.toggletag),
  awful.button({ }, maus.WHEEL_UP, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button({ }, maus.WHEEL_DOWN, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
  awful.button({ }, maus.LEFT,
    function (c)
      if c == client.focus then
        c.minimized = true
      else
        -- Without this, the following
        -- :isvisible() makes no sense
        c.minimized = false
        if not c:isvisible() then
          awful.tag.viewonly(c:tags()[1])
        end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
      end
    end),
  awful.button({ }, maus.RIGHT,
    function (c)
      if instance then
        instance:hide()
        instance = nil
      else
        --instance = awful.menu.clients({
        --  theme = { width = 250 }
        --})

        instance = context_menu(c)
      end
    end),
  awful.button({ }, maus.WHEEL_UP,
    function ()
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
    end),
  awful.button({ }, maus.WHEEL_DOWN,
    function ()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end))

for s = 1, screen.count() do
  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt()
  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, maus.RIGHT, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, maus.LEFT, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, maus.WHEEL_UP, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, maus.WHEEL_DOWN, function () awful.layout.inc(layouts, -1) end)))
  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Create the wibox
  mywibox[s] = awful.wibox({ position = "top", height = 16, screen = s })

  -- Создаем основную панель
  top_panel_box[s] = ({ position = "top", height = 16, screen = s })

  -- Создаем нижнюю панель
  bottom_panel_box[s] = awful.wibox({ position = "bottom", height = 16, screen = s })

  --quake
  quakeconsole[s] = quake({ terminal = config.terminal, height = 0.8, screen = s })

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(start_button)
  left_layout:add(mytaglist[s])

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(split_line)
  right_layout:add(fs_root)
  right_layout:add(split_line)
  right_layout:add(battery_widget)
  right_layout:add(split_line)
  right_layout:add(keyboard)
  right_layout:add(split_line)
  --right_layout:add(APW)
  right_layout:add(mytextclock)
  right_layout:add(mylayoutbox[s])

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_right(right_layout)

  local botom_left_layer = wibox.layout.fixed.horizontal()
  botom_left_layer:add(mypromptbox[s])
  botom_left_layer:add(mytasklist[s])
  botom_left_layer:add(wibox.widget.systray())

  local botom_layout = wibox.layout.align.horizontal()
  botom_layout:set_left(botom_left_layer)

  mywibox[s]:set_widget(layout)
  bottom_panel_box[s]:set_widget(botom_layout)
  --top_panel_box[s]:set_widget(layout)
end
--<<

-->>Хоткеи
--Мышка
root.buttons(awful.util.table.join(
  awful.button({ }, maus.RIGHT, function () mymainmenu:toggle() end),
  awful.button({ }, maus.WHEEL_UP, awful.tag.viewnext),
  awful.button({ }, maus.WHEEL_DOWN, awful.tag.viewprev)
))

--Клавиатура
globalkeys = awful.util.table.join(
  awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
  awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
  awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

  awful.key({ modkey,           }, "j",
    function ()
      awful.client.focus.byidx( 1)
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey,           }, "k",
    function ()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end),

  -- Layout manipulation
  awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
  awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
  awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
  awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
  awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
  awful.key({ modkey,           }, "Tab",
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end),

  -- Standard program
  awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
  awful.key({ modkey, "Control" }, "r", awesome.restart),
  awful.key({ modkey, "Shift"   }, "q", awesome.quit),

  awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
  awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
  awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
  awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
  awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
  awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

  awful.key({ modkey, "Control" }, "n", awful.client.restore),

  -- Brightness
  awful.key({ }, "XF86MonBrightnessDown",
    function ()
      awful.util.spawn("xbacklight -dec 5")
    end),
  awful.key({ }, "XF86MonBrightnessUp",
    function ()
      awful.util.spawn("xbacklight -inc 5")
    end),

  --Audio control
  --awful.key({ }, "XF86AudioRaiseVolume",  APW.Up),
  --awful.key({ }, "XF86AudioLowerVolume",  APW.Down),
  --awful.key({ }, "XF86AudioMute",         APW.ToggleMute),

  awful.key({ }, "XF86AudioRaiseVolume", 
    function ()
      awful.util.spawn("amixer set Master 5%+") 
    end),
  awful.key({ }, "XF86AudioLowerVolume", 
    function ()
      awful.util.spawn("amixer set Master 5%-") 
    end),
  awful.key({ }, "XF86AudioMute", 
    function ()
      awful.util.spawn("amixer sset Master toggle") 
    end),

  -- Prompt
  --awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
  awful.key({ modkey },            "r",     function () awful.util.spawn("rofi -show run")  end),
  awful.key({ modkey,           }, "w", function () awful.util.spawn("rofi -show window") end),
  awful.key({ modkey,           }, "s", function () awful.util.spawn("rofi -show ssh") end),
  awful.key({ modkey, "Shift"   }, "r",
    function ()
      awful.prompt.run({ prompt = "Запуск в терминале: " },
      mypromptbox[mouse.screen].widget, function (...) awful.util.spawn(config.terminal .. " -e " .. ...) end,
      awful.completion.shell,
      awful.util.getdir("cache") .. "/history")
    end),

  -- Screen lock
  awful.key({ modkey, "Control" }, "l", function () awful.util.spawn("xscreensaver-command -lock") end),

  awful.key({ modkey }, "g",
    function ()
      awful.prompt.run({ prompt = "Web search: " }, mypromptbox[mouse.screen].widget,
        function (command)
          awful.util.spawn("google-chrome-stable 'http://yubnub.org/parser/parse?command="..command.."'", false)
          -- Switch to the web tag, where Firefox is, in this case tag 3
          if tags[mouse.screen] then awful.tag.viewonly(tags[mouse.screen][1]) end
        end)
      end),

  --awful.key({ modkey            }, "b",
  --  function ()
  --    awful.prompt.run({ prompt = "Calculate: " }, mypromptbox[mouse.screen].widget,
  --      function (expr)
  --        local result = awful.util.eval("return (" .. expr .. ")")
  --        naughty.notify({ text = expr .. " = " .. result, timeout = 10 })
  --      end
  --    )
  --  end),

  awful.key({ modkey },            "x",
    function ()
      awful.prompt.run({ prompt = "Run Lua code: " },
      mypromptbox[mouse.screen].widget,
      awful.util.eval, nil,
      awful.util.getdir("cache") .. "/history_eval")
    end),
  -- Menubar
  --awful.key({ modkey }, "p", function() menubar.show() end)
  awful.key({ modkey },            "p",
    function ()
      awful.util.spawn("dmenu_run -i -p 'Run command:' -nb '" .. beautiful.bg_normal .. "' -nf '" .. beautiful.fg_normal .. "' -sb '" .. beautiful.bg_focus .. "' -sf '" .. beautiful.fg_focus .. "'")
    end),

  --quake
  awful.key({ modkey }, "`", function () quakeconsole[mouse.screen]:toggle() end),

  -- translate
  awful.key ({modkey, "Control" }, "t", function () clip_translate() end),

  -- Screenshot
  awful.key({   },                 "Print",
    function()
      awful.util.spawn("scrot '/home/rb/Downloads/%Y-%m-%d-%H-%M-%S.png'")
    end),
  awful.key({ "Control" },           "Print",
    function()
      awful.util.spawn("sleep 0.5 && scrot -u '/home/rb/Downloads/window_%Y-%m-%d-%H-%M-%S.png'")
    end),
  awful.key({ "Shift" },             "Print",
    function()
      awful.util.spawn_with_shell("sleep 0.5 && scrot -b -s '/home/rb/Downloads/region_%Y-%m-%d-%H-%M-%S.png'")
    end)

)

clientkeys = awful.util.table.join(
  awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
  awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
  awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
  awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
  awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
  awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
  --awful.key({ modkey, "Control" }, "v", lain.util.magnify_client),
  awful.key({ modkey, "Shift" }, "t",
    function (c)
      if   c.titlebar then awful.titlebar.remove(c)
      else awful.titlebar:add(c, { modkey = modkey }) end
    end),
  awful.key({ modkey, "Control" }, "i",
    function (c)
      naughty.notify({ text =
        "Class: " .. c.class ..
        "\nInstance: " .. c.instance ..
        "\nName: " .. c.name .. "\n",
      width = 400 })
    end),
  awful.key({ modkey,           }, "n",
    function (c)
      -- The client currently has the input focus, so it cannot be
      -- minimized, since minimized clients can't have the focus.
      c.minimized = true
    end),
  awful.key({ modkey,           }, "m",
    function (c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical   = not c.maximized_vertical
    end),
      -- help menu
  awful.key({ modkey,}, "z",
    function (c)
      if notifyHide(help_notify) then
        help_notify = help.getClientName(c)
      else
        help_notify = nil
      end
    end) ,
  awful.key({ modkey, "Shift"}, "z",
    function ()
      if notifyHide(help_notify) then
        help_notify = help.displayHelp("Awesome")
      else
        help_notify = nil
      end
    end),

  awful.key({ modkey}, "d", function ()
    info = true
    awful.prompt.run({ fg_cursor = "black",bg_cursor="orange", prompt = "<span color='#008DFA'>Dict:</span> " }, 
    mypromptbox[mouse.screen],
    function(word)
      local f = io.popen("dict -d wn " .. word .. " 2>&1")
      local fr = ""
      for line in f:lines() do
        fr = fr .. line .. '\n'
      end
      f:close()
      naughty.notify({ text = '<span font_desc="Sans 7">'..fr..'</span>', timeout = 0, width = 400 })
    end,
    nil, awful.util.getdir("cache") .. "/dict") 
  end)
)

-->>Привязка хоткеев к окружению
for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9,
      function ()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[i]
        if tag then
          awful.tag.viewonly(tag)
        end
      end),
    -- Toggle tag.
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function ()
        local screen = mouse.screen
        local tag = awful.tag.gettags(screen)[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function ()
        if client.focus then
          local tag = awful.tag.gettags(client.focus.screen)[i]
          if tag then
            awful.client.movetotag(tag)
          end
        end
      end),
    -- Toggle tag.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function ()
        if client.focus then
          local tag = awful.tag.gettags(client.focus.screen)[i]
          if tag then
            awful.client.toggletag(tag)
          end
        end
      end))
end

clientbuttons = awful.util.table.join(
  awful.button({ }, maus.LEFT, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, maus.LEFT, awful.mouse.client.move),
  awful.button({ modkey }, maus.RIGHT, awful.mouse.client.resize))

root.keys(globalkeys)
--<<

-->>Правила
awful.rules.rules = {
  { rule = { },
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons } },

  { rule = { class = "MPlayer" },
    properties = {
      floating = true } },

  { rule = { class = "pinentry" },
    properties = {
      floating = true } },

  { rule = { class = "gimp" },
    properties = {
      floating = true } },

  { rule = { class = "Firefox" },
    properties = {
      tag = tags[1][2] } },

  { rule = { class = "google-chrome" },
    properties = {
      tag = tags[1][1] } },

  { rule = { class = "Skype"},
    properties = {
      tag = tags[1][4] } },

  { rule = { class = "telegram-desktop"},
    properties = {
      tag = tags[1][4] } },

  { rule = { class = "Claws-mail"},
    properties = {
      tag = tags[1][5] } },
  { rule = { class = "Pidgin", role = "buddy_list"},
     properties = {
       tag = tags[1][4] } },
   { rule = { class = "Pidgin", role = "conversation"},
     properties = {
       tag = tags[1][4]},
     callback = awful.client.setslave }
}
--<<

-->>Сигналы
client.connect_signal("manage", function (c, startup)
  -- Enable sloppy focus
  c:connect_signal("mouse::enter",
    function(c)
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

  local titlebars_enabled = false
  if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
      awful.button({ }, maus.LEFT,
        function()
          client.focus = c
          c:raise()
          awful.mouse.client.move(c)
        end),
      awful.button({ }, maus.RIGHT,
        function()
          client.focus = c
          c:raise()
          awful.mouse.client.resize(c)
        end)
    )

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(awful.titlebar.widget.iconwidget(c))
    left_layout:buttons(buttons)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(awful.titlebar.widget.floatingbutton(c))
    right_layout:add(awful.titlebar.widget.maximizedbutton(c))
    right_layout:add(awful.titlebar.widget.stickybutton(c))
    right_layout:add(awful.titlebar.widget.ontopbutton(c))
    right_layout:add(awful.titlebar.widget.closebutton(c))

    -- The title goes in the middle
    local middle_layout = wibox.layout.flex.horizontal()
    local title = awful.titlebar.widget.titlewidget(c)
    title:set_align("center")
    middle_layout:add(title)
    middle_layout:buttons(buttons)

    -- Now bring it all together
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_right(right_layout)
    layout:set_middle(middle_layout)

    awful.titlebar(c):set_widget(layout)
  end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

--function run_once(cmd)
--  findme = cmd
--  firstspace = cmd:find(" ")
--  if firstspace then
--    findme = cmd:sub(0, firstspace-1)
--  end
--  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
--end

function run_once(prg,arg_string,pname,screen)
  if not prg then
    do return nil end
  end
  if not pname then
    pname = prg
  end
  if not arg_string then 
    awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
  else
    awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. " ".. arg_string .."' || (" .. prg .. " " .. arg_string .. ")",screen)
  end
end

run_once("kbdd")
run_once("urxvtd", "--quiet --fork --opendisplay")
run_once("dbus-launch nm-applet &", nil, "nm-applet")
run_once("xscreensaver","-no-splash")
run_once("pidgin",nil,nil,2)
run_once("wicd-client",nil,"/usr/bin/python2 -O /usr/share/wicd/gtk/wicd-client.py")
run_once("setxkbmap -layout 'us,ru(winkeys)' -option grp:caps_toggle")
run_once("xset r rate 200 30")
run_once("xrdb -load ~/.Xresources")
run_once("ogg123 -q '/home/rb/.config/awesome/sounds/desktop-login.ogg'")
run_once("telegram-desktop")
run_once("skype")
run_once("google-chrome-stable")
