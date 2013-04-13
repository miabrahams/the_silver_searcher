-- to generate Visual Studio files in vs-premake directory, run:
-- premake4 vs2010 or premake4 vs2008

-- common settings for solutions
function solution_common()
  configurations { "Debug", "Release" }
  location "vs-premake" -- this is where generated solution/project files go

  -- Symbols - generate .pdb files
  -- StaticRuntime - statically link crt
  -- ExtraWarnings - set max compiler warnings level
  -- FatalWarnings - compiler warnigs are errors'
  -- NoMinimalRebuild - disable /Gm because it clashes with /MP
  flags {
   "Symbols", "StaticRuntime",
   "NoRTTI", "Unicode", "NoExceptions", "NoMinimalRebuild"
  }

  configuration "Debug"
    targetdir "dbg" -- this is where the .exe/.lib etc. files wil end up
    defines { "_DEBUG", "DEBUG" }

  configuration "Release"
     targetdir "rel"
     flags { "Optimize" }
     defines { "NDEBUG" }
     -- 4189 - variable not used, happens with CrashIf() macros that are no-op
     --        in release builds
     buildoptions { "/wd4189" }

  configuration {"vs*"}
    -- defines { "_WIN32", "WIN32", "WINDOWS", "_CRT_SECURE_NO_WARNINGS" }
    defines { "_WIN32", "WIN32", "WINDOWS", "_CRT_SECURE_NO_WARNINGS" }
    -- 4800 - int -> bool coversion
    -- 4127 - conditional expression is constant
    -- 4100 - unreferenced formal parameter
    -- 4244 - possible loss of data due to conversion
    -- /MP  - use multi-cores for compilation
    buildoptions {
        "/wd4800", "/wd4127", "/wd4100", "/wd4244"
    }
end

solution "ag"
  solution_common()

  project "ag"
    kind "ConsoleApp"
    language "C++"
    files {
      "src/*.h",
      "src/*.c",
      "wincompat/dirent.*",
      "wincompat/getopt.*",
      "wincompat/unistd.*",
    }

    configuration {"vs*"}
      -- /TP  - compile as c++
      buildoptions { "/TP" }

    includedirs { "src", "wincompat", "wincompat/zlib", "wincompat/pcre-8.32",
    "wincompat/pthread-win32" }
    linkoptions {"/NODEFAULTLIB:\"msvcrt.lib\""}
    links { "Shlwapi", "zlib", "pthread-win32" }

  project "zlib"
     kind "StaticLib"
     language "C"
     files { "wincompat/zlib/*.c", "wincompat/zlib/*.h" }
     excludes { "wincompat/zlib/gzclose.c", "wincompat/zlib/gzread.c", "wincompat/zlib/gzwrite.c", "wincompat/zlib/gzlib.c"}
     includedirs { "wincompat/zlib" }

  project "pthread-win32"
     kind "StaticLib"
     language "C"
     files {
        "wincompat/pthread-win32/*.h",
        "wincompat/pthread-win32/pthread.c"
     }
     includedirs { "wincompat/pthread-win32" }