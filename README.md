
# Overlord

## Upcoming Features
```
 - Start Screen.
 - End Screen.
 - Mob bouncing.
 - 
 - AI Mobs.                             CHECK
 - Add beep sounds.                     CHECK
 - Create Ball object.                  CHECK
 - Push/Roll/Kick Ball around screen.   CHECK
 - Create AI Mob Units to roam map.     CHECK
 - Add Pushable Blocks.
 - Add Button Tiles.
```
## Class Mapping
```
   o wads ----  [ widgets ]
   | 
   o rdia ----  [ ProgressBar, Point, GameObject,
  / \             Ball, Player, GridDisplay ]
 /   \
/     o overlord   ---- [ Overlord < Scroller3 ]
|     |   \
|     |    o require 'scroller3', 'pathfinder', 'objects'
|     /\
|    /  o scroller3  ---- [ Scroller3 < RdiaGame,
|   /    \    \             OverDisplay < ScrollerDisplay ]
|   |     \    \
|   |      \    o require 'display', 'characters',
|   |      |\             'items',  'themes'
|   |      | \
|   |      |\ o display   ---- [ ScrollerDisplay < Widgets ]
|   |      | \
|   |      |\ o characters --- [ Character < GameObject ]
|   |      | \
|   |      |  o items     ---- [ Wall, Brick, Dot, OutOfBounds,
|   |      |\                    BackgroundArea, ForegroundArea,
|   |      | \                   GoalArea < GameObject ]
|   |       \ o objects   ---- [ Ballrag < GameObject ]
|   |        \
|   \         o themes    ---- [ BricksTheme < GuiTheme ]
|    \            # WadsConfig.instance.set_current_theme(BricksTheme.new)
|\    \
| \    o pathfinder  ---- [ Pathfinder ]
|  \
|\  o map_editor
| \  
|  \
|   o rdia  require 'version' 'widgets' 'app'
|   |\
|   | o app ---- [ RdiaGame < WasdApp ]
|   |  \
|   |   o Module ---- constants ( RDIA_MODE_START, etc. )
|    \
|     o widgets ---- [ ProgressBar < Wiget,
|                      Point,
|                      GameObject < ImageWidget,
|                      Ball < GameObject,
|                      Player < GameObject,
 \                     GridDisplay < Widget ]
  \
   \
    o wads  require 'version' 'data_structure' 'widgets' 'text_input' 'app'
     \
      o app ---- [ WadsApp < GosuWindow. ]
       \  
        \      o data_structures [ HashOfHashes, GraphReverseIterator,
         \    /                    Stats, Node, Edge, Graph, 
          \  /                     DataRange, VisibleRange ]
           \/
            o widgets [ Coordinates,
           /            WadsConfig,
          /             GuiContainer, 
         /              Widget,
        /                 Panel,
       /                  ImageWidget,
      /                   Text,
      |                   ErrorMessage,
      |                   PlotPoint,                      
      |                   Button,
      |                   DeleteButton,
      |                   Document,
      |                   InfoBox,
      |                   Dialog,
      |                   WidgetResult,
      |                   Line,
      |                   AxisLines
      |                   VerticalAxisLable,
      |                   HorizontalAxisLable,
      |                   Table,
      |                   SingleSelectTable,
      |                   MultiSelectTable,
      |                   Plot,
      |                   Node Widget,
      |                   NodeIconWidget,
     /\                   GraphWidget ]
    /  \
   /    \
  /\     o textinput  [ TextField < Gosu::TextInput ]
 /  \
/    o themes   [ GuiTheme,
|                 WadsBrightTheme,
|                 WadsDarkRedBrownTheme,
|                 WadsEarthTonesTheme,
|                 WadsNatureTheme,
|                 WadsPurpleTheme,
|                 WadsAquaTheme,
\                 WadsNoIconTheme ]
 \
  o layouts  [ WadsLayout,
               SectionLayout,
               VerticalColumnLayout,
               HeaderContentLayout,
               ContentFooterLayout,
               EastWestLayout,
               TopMiddleBottomLayout,
               BorderLayout ]
```

## Installation
```
git clone https://github.com/EagleDog/overlord.git
cd overlord
bundle install
ruby overlord.rb
```

## Instructions

Movement:
```
A/S/D/W  ----  move
Arrows   ----  move
```

## Credits
Credit to Lanea Zimmerman for tiles artwork.


