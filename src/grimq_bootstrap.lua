-- ============================================================
-- BOOTSTRAP CODE
-- ============================================================

function _banner()
	logi("GrimQ Version " .. LIB_VERSION_TEXT .. VERSION_SUFFIX .. " - Marco Mastropaolo (Xanathar)")
end

-- added by JKos -- note: as of v1.5 grimq *REQUIRES* jkos fw.
function activate()
	logi("Starting with jkos-fw bootstrap...")
	grimq._activateAutos()
	grimq._activateJKosFw()
end

_banner()

MAXLEVEL = getMaxLevels()

if (isWall == nil) then
	loge("This version of GrimQ requires Legend of Grimrock 1.3.6 or later!")
end


















