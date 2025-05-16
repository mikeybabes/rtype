

REM Combine seperate bitplanes into larger version as ROMs of the day had a limit!
copy /b rt2_a-g00.ic50+rt2_a-g01.ic51 plane0.bin
copy /b rt2_a-g10.ic56+rt2_a-g11.ic57 plane1.bin
copy /b rt2_a-g20.ic65+rt2_a-g21.ic66 plane2.bin
copy /b rt2_a-g30.ic63+rt2_a-g31.ic64 plane3.bin

REM We take the bitplanes and put in order of 4bits / pixel into one big FO binary.
python .\python\plane4.py plane3.bin plane2.bin plane1.bin plane0.bin gfx2.bin

DEL plane0.bin
DEL plane1.bin
DEL plane2.bin
DEL plane3.bin

REM Interleave the low and high roms into linear format
python .\python\merge-binaries.py rt2_a-l0-d.ic60 rt2_a-h0-d.ic54 cpu1.bin 1
python .\python\merge-binaries.py rt2_a-l1-d.ic59 rt2_a-h1-d.ic53 cpu2.bin 1
REM join the two together just standard dos copy command.
copy /b cpu1.bin+cpu2.bin cpu.bin
REM just delete the temp two files.
DEL cpu1.bin
DEL cpu2.bin

REM this is the raw palette data inside the ROMs (well rom in our case)
REM not these is a standard R,G,B which maps to 16 palettes but in the hardware limit of 5bits for each RGB
python .\python\savebit2.py cpu.bin original-palettes.bin 2d000 2ffff

REM So this just does a little check to make sure this data is valid
python .\python\check_file_structure.py original-palettes.bin
python .\python\validate_palette.py original-palettes.bin

REM so we convert this 5bit RGB into 8bit which modern systems need
REM note we can't seem to replicate the identical method which mame seems to use from it's pallette.h source (you go check!)
python .\python\convert_palette.py original-palettes.bin rom-palettes.bin
DEL original-palettes.bin

REM This generates an all-palettes.png so you can get a visual of what's used inside the game
REM the palette is 4k image you can see it's split in two halves between 0 - 127 which is 16 palette chunks
REM and the 2nd half is the foreground and background characters (level maps)
python .\python\generate_palettes16.py rom-palettes.bin all-palettes.png --block --number --grid

REM we found the tiles are stored as unpacked data inside the ROM
python .\python\savebit.py cpu.bin tiles.bin 30000 3a000

REM this makes us one might big tiles.png just to show we have the 4x4 tiles all plotted (some unused)
python .\python\rtype2_tile_plot.py tiles.bin gfx2.bin stage1.pal tiles.png

python .\python\map_analysis.py maps.bin
python .\python\map_analysys.py stage1-fg.bin

python .\python\savebit.py cpu.bin stage1-FGmap.bin 6B000 780
python .\python\savebit.py cpu.bin stage2-FGmap.bin 6C370 810
python .\python\savebit.py cpu.bin stage3-FGmap.bin 6B870 A10
python .\python\savebit.py cpu.bin stage4-FGmap.bin 6CC70 BD0
python .\python\savebit.py cpu.bin stage5-FGmap.bin 6E270 730
python .\python\savebit.py cpu.bin stage6-FGmap.bin 6EAB0 1250
python .\python\savebit.py cpu.bin stage1-BGmap.bin 6FF40 510
python .\python\savebit.py cpu.bin stage2-BGmap.bin 70A40 770
python .\python\savebit.py cpu.bin stage3-BGmap.bin 704C0 2B0
python .\python\savebit.py cpu.bin stage4-BGmap.bin 711C0 F90
python .\python\savebit.py cpu.bin stage5-BGmap.bin 71FC0 1460
python .\python\savebit.py cpu.bin stage6-BGmap.bin 73460 420

python .\python\generate_palettes16.py rom-palettes.bin all-palettes.png --block --number --grid

python .\python\splitchunks.py rom-palettes.bin Palettes.pal 768

ren Palettes_9.pal level1.pal
REM we need to copy in palette 28 from rom into pallete 11 for this level to be correct
python .\python\python palette_change.py rom-palettes.bin level1.pal 28 11

REM Now we create the maps using the ROM palettes which have been created from the game ROM contents
python .\python\rtype2_map_plot.py stage1-FGmap.bin tiles.bin gfx2.bin level1.pal stage1FG-map.png
python .\python\rtype2_map_plot.py stage1-BGmap.bin tiles.bin gfx2.bin level1.pal stage1BG-map.png
ren Palettes_11.pal level2.pal
python .\python\rtype2_map_plot.py stage2-FGmap.bin tiles.bin gfx2.bin level2.pal stage2FG-map.png
python .\python\rtype2_map_plot.py stage2-BGmap.bin tiles.bin gfx2.bin level2.pal stage2BG-map.png
ren Palettes_10.pal level3.pal
python .\python\rtype2_map_plot.py stage3-FGmap.bin tiles.bin gfx2.bin level3.pal stage3FG-map.png
python .\python\rtype2_map_plot.py stage3-BGmap.bin tiles.bin gfx2.bin level3.pal stage3BG-map.png
ren Palettes_13.pal level4.pal
python .\python\palette_change.py rom-palettes.bin level4.pal 128 0 91 7 91 8 128 9 91 10 91 11 91 12 91 13
python .\python\rtype2_map_plot.py stage4-FGmap.bin tiles.bin gfx2.bin level4.pal stage4FG-map.png
python .\python\rtype2_map_plot.py stage4-BGmap.bin tiles.bin gfx2.bin level4.pal stage4BG-map.png --height 16
ren Palettes_15.pal level5.pal
python .\python\palette_change.py rom-palettes.bin level5.pal 251 11 252 12 253 13 254 14 255 15

python .\python\rtype2_map_plot.py stage5-FGmap.bin tiles.bin gfx2.bin level5.pal stage5FG-map.png
python .\python\rtype2_map_plot.py stage5-BGmap.bin tiles.bin gfx2.bin level5.pal stage5BG-map.png --height 16
ren Palettes_14.pal level6.pal
python .\python\palette_change.py rom-palettes.bin level6.pal 233 9 234 10 235 11 236 12 237 13 238 14 239 15
python .\python\rtype2_map_plot.py stage6-FGmap.bin tiles.bin gfx2.bin level6.pal stage6FG-map.png
python .\python\rtype2_map_plot.py stage6-BGmap.bin tiles.bin gfx2.bin level6.pal stage6BG-map.png

REM this is a visual aid which creates a solid colour which is the palette for the tile
REM the palette change used had to modify the palette chunks per level, during gameplay they were dynamically changed
REM the coloured boxes here at index coloured PNGs so you can see what tile palette used.
python .\python\rtype2_map_plot_box16.py stage1-FGmap.bin tiles.bin gfx2.bin level1.pal stage1FG-box.png
python .\python\rtype2_map_plot_box16.py stage2-FGmap.bin tiles.bin gfx2.bin level2.pal stage2FG-box.png
python .\python\rtype2_map_plot_box16.py stage3-FGmap.bin tiles.bin gfx2.bin level3.pal stage3FG-box.png
python .\python\rtype2_map_plot_box16.py stage4-FGmap.bin tiles.bin gfx2.bin level4.pal stage4FG-box.png
python .\python\rtype2_map_plot_box16.py stage5-FGmap.bin tiles.bin gfx2.bin level5.pal stage5FG-box.png
python .\python\rtype2_map_plot_box16.py stage6-FGmap.bin tiles.bin gfx2.bin level6.pal stage6FG-box.png

python .\python\rtype2_map_plot_box16.py stage1-BGmap.bin tiles.bin gfx2.bin level1.pal stage1BG-box.png
python .\python\rtype2_map_plot_box16.py stage2-BGmap.bin tiles.bin gfx2.bin level2.pal stage2BG-box.png
python .\python\rtype2_map_plot_box16.py stage3-BGmap.bin tiles.bin gfx2.bin level3.pal stage3BG-box.png
python .\python\rtype2_map_plot_box16.py stage4-BGmap.bin tiles.bin gfx2.bin level4.pal stage4BG-box.png --height 16
python .\python\rtype2_map_plot_box16.py stage5-BGmap.bin tiles.bin gfx2.bin level5.pal stage5BG-box.png --height 16
python .\python\rtype2_map_plot_box16.py stage6-BGmap.bin tiles.bin gfx2.bin level6.pal stage6BG-box.png

python .\python\generate_single_palette_grid.py level1.pal stage1-palettes.png
python .\python\generate_single_palette_grid.py level2.pal stage2-palettes.png
python .\python\generate_single_palette_grid.py level3.pal stage3-palettes.png
python .\python\generate_single_palette_grid.py level4.pal stage4-palettes.png
python .\python\generate_single_palette_grid.py level5.pal stage5-palettes.png
python .\python\generate_single_palette_grid.py level6.pal stage6-palettes.png

