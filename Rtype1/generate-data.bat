REM Interleave the low and high roms into linear format
python .\python\merge-binaries.py rt_r-l0-b.3b rt_r-h0-b.1b cpu1.bin 1
python .\python\merge-binaries.py rt_r-l1-b.3c rt_r-h1-b.1c cpu2.bin 1
REM join the two together just standard dos copy command.
copy /b cpu1.bin+cpu2.bin cpu.bin
REM just delete the temp two files.
DEL cpu1.bin
DEL cpu2.bin


REM Rtype Palettes with a big gap of blanks, which we need to ignore 3B000 - 3f200
REM We're save two chunks for first 8 then another 8 with a little gap between the two sets
python .\python\savebit.py cpu.bin palettes-all-1st.bin 3b000 1800
python .\python\savebit.py cpu.bin palettes-all-2nd.bin 3d700 1800

REM join the two together
copy /b palettes-all-1st.bin+palettes-all-2nd.bin original-palettes.bin

REM So this just does a few little checks to make sure this data is valid
python .\python\check_file_structure.py original-palettes.bin
python .\python\validate_palette.py original-palettes.bin

REM so we convert this 5bit RGB into 8bit which modern systems need
REM note we replicate the identical method which mame uses from it's pallette.h source (you go check!), perhaps not technically the most accurate as there are minor rounding errors, but nobody would ever notice.
python .\python\convert_palette.py original-palettes.bin rom-palettes.bin

REM we'll make a PNG of all palettes as a visual guide
python .\python\generate_palettes16.py rom-palettes.bin all-palettes.png --block --number --grid

REM The game palettes seem to match the 2nd chunk of palettes above so we use them for plotting assets
REM so let's just use the 2nd chunk of palettes above
python .\python\convert_palette.py palettes-all-2nd.bin stage-palettes.bin
python .\python\splitchunks.py stage-palettes.bin stage.pal 768

REM these are not needed, but were used in debugging
python .\python\generate_single_palette_grid.py stage_1.pal stage1-palette.png
python .\python\generate_single_palette_grid.py stage_2.pal stage2-palette.png
python .\python\generate_single_palette_grid.py stage_3.pal stage3-palette.png
python .\python\generate_single_palette_grid.py stage_4.pal stage4-palette.png
python .\python\generate_single_palette_grid.py stage_5.pal stage5-palette.png
python .\python\generate_single_palette_grid.py stage_6.pal stage6-palette.png
python .\python\generate_single_palette_grid.py stage_7.pal stage7-palette.png
python .\python\generate_single_palette_grid.py stage_8.pal stage8-palette.png

REM Both FG and BG graphics are stored as 1bit planes 4 in total for 4bit colour format characters
python .\python\plane4.py rt_b-a3.ic23 rt_b-a2.ic20 rt_b-a1.ic22 rt_b-a0.ic20 gfx2.bin
python .\python\plane4.py rt_b-b3.ic24 rt_b-b2.ic25 rt_b-b1.ic27 rt_b-b0.ic26 gfx3.bin

REM Map master tiles are a big chunk inside main code roms
python .\python\savebit.py cpu.bin tiles-3bytes-8x6.bin 30000 9000

python .\python\rtype_meta_tile_viewer.py tiles-3bytes-8x6.bin gfx3.bin stage-palettes.bin gfx3-tiles.png --grid
python .\python\rtype_meta_tile_viewer.py tiles-3bytes-8x6.bin gfx2.bin stage-palettes.bin gfx2-tiles.png --grid

REM This grabs both FG and BG stage/level map data. Some a little longer than needed as the system plots tile not visable before displayed during game play, but you don't see them as game reaches a stop position. 
python .\python\savebit.py cpu.bin stage1-FGmap.bin 1C627 294
python .\python\savebit.py cpu.bin stage2-FGmap.bin 1C8BB 1E0
python .\python\savebit.py cpu.bin stage3-FGmap.bin 1CA9B 1E0
python .\python\savebit.py cpu.bin stage4-FGmap.bin 1CC7B 1E0
python .\python\savebit.py cpu.bin stage5-FGmap.bin 1CE5B 1E0
python .\python\savebit.py cpu.bin stage6-FGmap.bin 1D03B 1E0
python .\python\savebit.py cpu.bin stage7-FGmap.bin 1D21B 1E0
python .\python\savebit.py cpu.bin stage8-FGmap.bin 1D3FB 19A

python .\python\savebit.py cpu.bin stage1-BGmap.bin 1D68F 348
python .\python\savebit.py cpu.bin stage2-BGmap.bin 1D9D7 10E
python .\python\savebit.py cpu.bin stage3-BGmap.bin 1DAE5 2B2
python .\python\savebit.py cpu.bin stage4-BGmap.bin 1DD97 3C0
python .\python\savebit.py cpu.bin stage5-BGmap.bin 1E157 1E0
python .\python\savebit.py cpu.bin stage6-BGmap.bin 1E337 3C0
python .\python\savebit.py cpu.bin stage7-BGmap.bin 1E6F7 168
python .\python\savebit.py cpu.bin stage8-BGmap.bin 1E85F 262

REM this now makes transparent background PNGs 8bit colour from 4bit tiles and palettes as per the games visuals
REM Note the parallex effect means forground and backgrounds move at a different pace, sometimes matching up and other not.
REM this the reason why both are mostly different lengths. The python plot reports how many strips it's processed.
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx2.bin stage_1.pal stage1-FGmap.bin stage1-FGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx3.bin stage_1.pal stage1-BGmap.bin stage1-BGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx2.bin stage_2.pal stage2-FGmap.bin stage2-FGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx3.bin stage_2.pal stage2-BGmap.bin stage2-BGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx2.bin stage_3.pal stage3-FGmap.bin stage3-FGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx3.bin stage_3.pal stage3-BGmap.bin stage3-BGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx2.bin stage_4.pal stage4-FGmap.bin stage4-FGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx3.bin stage_4.pal stage4-BGmap.bin stage4-BGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx2.bin stage_5.pal stage5-FGmap.bin stage5-FGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx3.bin stage_5.pal stage5-BGmap.bin stage5-BGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx2.bin stage_5.pal stage6-FGmap.bin stage6-FGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx3.bin stage_5.pal stage6-BGmap.bin stage6-BGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx2.bin stage_7.pal stage7-FGmap.bin stage7-FGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx3.bin stage_7.pal stage7-BGmap.bin stage7-BGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx2.bin stage_8.pal stage8-FGmap.bin stage8-FGmap.png
python .\python\rtype_master_map.py tiles-3bytes-8x6.bin gfx3.bin stage_8.pal stage8-BGmap.bin stage8-BGmap.png
