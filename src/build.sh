cd ..
mkdir build
cd src

cat lualinq_log.lua > lualinq_temp.lua
cat lualinq_ctor.lua >> lualinq_temp.lua
cat lualinq_froms.lua >> lualinq_temp.lua
cat lualinq_query.lua >> lualinq_temp.lua
cat lualinq_conversions.lua >> lualinq_temp.lua
cat lualinq_terminators.lua >> lualinq_temp.lua

cat lualinq_header.lua > ../build/lualinq.lua
cat lualinq_temp.lua >> ../build/lualinq.lua

cat lualinq_temp.lua > grimq_temp.lua
cat grimq_enums.lua >> grimq_temp.lua
cat grimq_froms.lua >> grimq_temp.lua
cat grimq_predicates.lua >> grimq_temp.lua
cat grimq_utils.lua >> grimq_temp.lua
cat grimq_string.lua >> grimq_temp.lua
cat grimq_auto.lua >> grimq_temp.lua
cat grimq_bootstrap.lua >> grimq_temp.lua

cat grimq_header.lua > ../build/grimq.lua
cat grimq_temp.lua >> ../build/grimq.lua

cat grimq_dbg_header.lua > ../build/grimq_debug.lua
cat grimq_temp.lua >> ../build/grimq_debug.lua

cat grimq_fw_header.lua > ../build/grimq_fw.lua
cat grimq_temp.lua >> ../build/grimq_fw.lua
cat grimq_fw_footer.lua >> ../build/grimq_fw.lua

cp grimqobjects.lua ../build/grimqobjects.lua

cp grimqunit.lua ../build/grimq_unit_tests.lua

cd ..

# this copies the content of the file to the clipboard - http://www.mastropaolo.com/txt2clip
# txt2clip build/grimq_debug.lua

mkdir -p release/grimq/framework
mkdir release/lualinq

cp build/grimq.lua release/grimq
cp build/grimq_fw.lua release/grimq/framework
cp build/lualinq.lua release/lualinq
cp docs/readme.txt release/lualinq
cp docs/readme.txt release/grimq

cp docs/LuaLinq.pdf release/lualinq
cp docs/GrimQ.pdf release/grimq

cd release
rm *.zip
cd grimq
7z a ../grimq.zip *.*
cd ..
cd lualinq
7z a ../lualinq.zip *.*

#pause

