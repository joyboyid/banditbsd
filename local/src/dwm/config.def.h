#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx                = 3;
static const unsigned int snap                    = 32;
static const int          gappx                   = 6;
static const int          swallowfloating         = 0;
static const int          smartgaps               = 1;
static const unsigned int systraypinning          = 0;
static const unsigned int systrayonleft           = 0;
static const unsigned int systrayspacing          = 2;
static const int          systraypinningfailfirst = 1;
static const int          showsystray             = 1;
static const int          showbar                 = 1;
static const int          topbar                  = 1;
static const unsigned int ulinepad                = 5;
static const unsigned int ulinestroke             = 2;
static const unsigned int ulinevoffset            = 0;
static const int          ulineall                = 0;
static const int          barpadding              = 4;
static const int          user_bh                 = 36;
static const char        *fonts[]                 = {
    "Monocraft:size=12", "Noto Sans Mono CJK HK:size=14",
    "JetBrainsMono Nerd Font Mono:style:medium:size=22",
    "Noto Color Emoji:size=12"};
/*Colorscheme*/
static const char  black[]         = "#141617";
static const char  gray1[]         = "#2d353b";
static const char  gray2[]         = "#343f44";
static const char  gray3[]         = "#7a8478";
static const char  gray4[]         = "#d3c6aa";
static const char  white[]         = "#d3c6aa";
static const char  blue[]          = "#7fbbb3";
static const char  cyan[]          = "#83c092";
static const char  green[]         = "#a7c080";
static const char  red[]           = "#e67e80";
static const char  orange[]        = "#e69875";
static const char  yellow[]        = "#dbbc7e";
static const char  pink[]          = "#d699b6";
static const char  col_borderbar[] = "#141617";
static const char *colors[][3]     = {
    [SchemeNorm] = {green, black, gray1},
    [SchemeSel]  = {white, black, gray3},
    [SchemeTag1] = {green, black, black},
    [SchemeTag2] = {red, black, black},
    [SchemeTag3] = {blue, black, black},
    [SchemeTag4] = {cyan, black, black},
    [SchemeTag5] = {orange, black, black},
    [SchemeTag6] = {yellow, black, black},
    [SchemeTag7] = {pink, black, black},
    [SchemeTag8] = {gray4, black, black},
    [SchemeTag9] = {gray2, black, black},
};
static const char *tagsel[][2] = {
    {gray3, black},
    {blue, black},
    {gray4, black},
    {cyan, black},
};

/* tagging */
static const char *tags[]  = {"一", "二", "三", "四", "五",
                              "六", "七", "八", "九"};
static const Rule  rules[] = {
    /*class         instance    title       tags mask  isfloating  iscentered
       isterminal noswallow   isfullscreen  monitor  scratchkey*/
    {"xterm-kitty", NULL, NULL, 0, 0, 1, 1, 0, 0, -1, 0},
    {NULL, NULL, "scratchpad", 0, 1, 1, 1, 0, 0, -1, 's'},
};

/* layout */
static const float mfact          = 0.5;
static const int   nmaster        = 1;
static const int   resizehints    = 1;
static const int   attachbelow    = 1;
static const int   lockfullscreen = 1;
static const int   refreshrate    = 60;

#define FORCE_VSPLIT 1

#include "vanitygaps.c"

static const Layout layouts[] = {
    {"[]=", tile},
    {"[M]", monocle},
    {"[@]", spiral},
    {"[\\]", dwindle},
    {"H[]", deck},
    {"TTT", bstack},
    {"===", bstackhoriz},
    {"HHH", grid},
    {"###", nrowgrid},
    {"---", horizgrid},
    {":::", gaplessgrid},
    {"|M|", centeredmaster},
    {">M>", centeredfloatingmaster},
    {"><>", NULL},
    {NULL, NULL},
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY, TAG)                                                      \
    {MODKEY, KEY, view, {.ui = 1 << TAG}},                                     \
        {MODKEY | ControlMask, KEY, toggleview, {.ui = 1 << TAG}},             \
        {MODKEY | ShiftMask, KEY, tag, {.ui = 1 << TAG}},                      \
        {MODKEY | ControlMask | ShiftMask, KEY, toggletag, {.ui = 1 << TAG}},

#define SHCMD(cmd)                                                             \
    {                                                                          \
        .v = (const char *[]) { "/bin/sh", "-c", cmd, NULL }                   \
    }

/* commands */
static const char *term[]          = {"st", NULL};
static const char *browser[]       = {"brave", NULL};
static const char *editor[]        = {"st", "-e", "nvim", NULL};
static const char *files[]         = {"st", "-e", "yazi", NULL};
static const char *scratchpadcmd[] = {
    "s",  "st",         "-t", "scratchpad", "-e", "tmux", "attach-session",
    "-t", "scratchpad", NULL};
static const char *launcher[]  = {"rofi",   "-show",
                                  "drun",   "-show-icons",
                                  "-theme", "~/.config/rofi/launcher.rasi",
                                  NULL};
static const char *wallpaper[] = {
    "sh", "-c", "~/.local/src/dwm/scripts/wallpapers.sh", NULL};
static const char *bookscmd[] = {"sh", "-c",
                                 "~/.local/src/dwm/scripts/books.sh", NULL};
static const char *power[]   = {"sh", "-c", "~/.local/src/dwm/scripts/power.sh",
                                NULL};
static const char *upvol[]   = {"sh", "-c",
                                "wpctl set-volume @DEFAULT_AUDIO_SINK@ -l 1.0 "
                                "10%+ && paplay ~/.config/dwm/pop.mp3",
                                NULL};
static const char *downvol[] = {"sh", "-c",
                                "wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%- && "
                                "paplay ~/.config/dwm/pop.mp3",
                                NULL};
static const char *mutevol[] = {"wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@",
                                "toggle", NULL};
static const char *screenshot[] = {
    "sh", "-c", "scrot -s ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png",
    NULL};
#include "movestack.c"
static const Key keys[] = {
    {MODKEY, XK_Return, spawn, {.v = term}},
    {MODKEY, XK_e, spawn, {.v = files}},
    {MODKEY, XK_b, spawn, {.v = browser}},
    {MODKEY, XK_v, spawn, {.v = editor}},
    {MODKEY, XK_d, spawn, {.v = launcher}},
    {MODKEY, XK_space, cyclelayout, {.i = +1}},
    {MODKEY | ShiftMask, XK_space, cyclelayout, {.i = -1}},
    {MODKEY, XK_w, spawn, {.v = wallpaper}},
    {MODKEY, XK_z, spawn, {.v = bookscmd}},
    {0, XF86XK_PowerOff, spawn, {.v = power}},
    {MODKEY, XK_s, togglegaps, {0}},
    {MODKEY, XK_p, togglescratch, {.v = scratchpadcmd}},
    {MODKEY | Mod1Mask, XK_q, quit, {0}},
    {MODKEY, XK_q, killclient, {0}},
    {MODKEY, XK_m, focusmaster, {0}},
    {MODKEY, XK_j, focusstack, {.i = +1}},
    {MODKEY, XK_k, focusstack, {.i = -1}},
    {MODKEY, XK_h, setmfact, {.f = -0.05}},
    {MODKEY, XK_l, setmfact, {.f = +0.05}},
    {MODKEY | ShiftMask, XK_j, movestack, {.i = +1}},
    {MODKEY | ShiftMask, XK_k, movestack, {.i = -1}},
    {Mod1Mask, XK_Tab, view, {0}},
    {MODKEY, XK_backslash, togglefloating, {0}},
    {MODKEY, XK_a, zoom, {0}},
    {MODKEY, XK_f, togglefullscr, {.v = &layouts[1]}},
    {0, XF86XK_AudioRaiseVolume, spawn, {.v = upvol}},
    {0, XF86XK_AudioLowerVolume, spawn, {.v = downvol}},
    {0, XF86XK_AudioMute, spawn, {.v = mutevol}},
    {0, XK_Print, spawn, {.v = screenshot}},
    TAGKEYS(XK_1, 0) TAGKEYS(XK_2, 1) TAGKEYS(XK_3, 2) TAGKEYS(XK_4, 3)
        TAGKEYS(XK_5, 4) TAGKEYS(XK_6, 5) TAGKEYS(XK_7, 6) TAGKEYS(XK_8, 7)
            TAGKEYS(XK_9, 8)};
static const Button buttons[] = {
    {ClkTagBar, 0, Button1, view, {0}},
    {ClkTagBar, 0, Button3, toggleview, {0}},
    {ClkTagBar, MODKEY, Button1, tag, {0}},
    {ClkTagBar, MODKEY, Button3, toggletag, {0}},
    {ClkClientWin, MODKEY, Button1, movemouse, {0}},
    {ClkClientWin, MODKEY, Button2, togglefloating, {0}},
    {ClkClientWin, MODKEY, Button3, resizemouse, {0}},
};
