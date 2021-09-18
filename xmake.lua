-- add rules: debug/release
add_rules("mode.debug", "mode.release")

-- define target
target("cairowidget")

    -- set kind
    set_kind("static")

    -- add files
    add_files("cairoglwindow.cpp")
    add_files("cairographicsdriver.cpp")
    add_files("caironanosvg.cpp")
    add_files("cairosurfacedevice.cpp")
    add_files("cairowidget.cpp")

    set_languages("c++20")

    if is_host("windows") then -- 在Windows上编译

        -- add_includedirs("D:/OpenFree/FLTK-1.3.6/include/FL/images")
        add_includedirs("D:/OpenFree/FLTK-1.3.6/include")
        add_includedirs("D:/OpenFree/Cairo-1.16.0/include")
        add_includedirs("D:/OpenFree/Cairo-1.16.0/include/cairo")

        add_defines("WIN32", "USE_OPENGL32", "_LARGEFILE_SOURCE", "_LARGEFILE64_SOURCE", "_FILE_OFFSET_BITS=64")
        add_ldflags("-mwindows", "-lole32", "-luuid", "-lcomctl32", "-lsetupapi")
        -- add_ldflags("-lglu32", "-lopengl32", "-lz")

        if is_arch("x86_64") then
            add_linkdirs("D:/OpenFree/FLTK-1.3.6/lib")

            if is_mode("release") then
                add_linkdirs("D:/OpenFree/Cairo-1.16.0/lib") -- Cairo静态库目录
                add_linkdirs("D:/OpenFree/Cairo-1.16.0/lib/dep") --Cairo静态依赖库目录
            elseif is_mode("debug") then
                add_linkdirs("D:/OpenFree/Cairo-1.16.0/bin") -- Cairo动态库路目录, 不需要指定动态依赖库, 只要允许程序时能找到依赖的dll即可
            end
        else
            add_linkdirs("D:/OpenFree/FLTK-1.3.6/lib/lib32")
        end

        -- add_links("ws2_32") -- windows.h与winsock2.h冲突, 暂时不解决
        -- add_links("wsock32") -- windows.h 包含winsock.h

    elseif is_host("linux") then -- 在Linux上编译

        add_includedirs("/usr/include")
        add_includedirs("/usr/include/cairo")
        --add_includedirs("/Softwares/FLTK-1.4.x/include")
        add_includedirs("/usr/local/bin/FLTK-1.4.x/include")
        add_includedirs("/usr/include/freetype2", "/usr/include/libpng16", "/usr/include/harfbuzz", "/usr/include/glib-2.0", "/usr/lib/glib-2.0/include")

        add_defines("USE_OPENGL32", "_LARGEFILE_SOURCE", "_LARGEFILE64_SOURCE", "_FILE_OFFSET_BITS=64", "_THREAD_SAFE", "_REENTRANT")
        add_ldflags("-lXrender", "-lXcursor", "-lXfixes", "-lXext", "-lXft", "-lfontconfig", "-lXinerama", "-lpthread", "-ldl", "-lm", "-lX11")

        --add_linkdirs("/Softwares/FLTK-1.4.x/lib")
        add_linkdirs("/usr/local/bin/FLTK-1.4.x/lib")
    end

    add_links("fltk")
    --add_ldflags("fltk_gl", "fltk_images", "fltk_forms", "fltk_png", "fltk_jpeg")
    add_links("fltk_cairo", "cairo") -- 取消此行注释以使用FLTK Cairo

    if is_mode("release") then -- 发布时使用静态库
        set_strip("all") -- 链接的时候，strip掉所有符号，包括调试符号

        if is_host("windows") then
            if is_arch("x86_64") then -- 64bit
                -- 下面这些库是Cairo的依赖库, rpcrt4是windows自动的dll，取消此行以使用Cairo
                -- 若没有这些库的话，可以下载emacs，emacs中带有这些库，libz(或zlib)改名为libz-9，libpng改名为libpng-9
                -- 在使用动态库时，还依赖libglib.dll, libiconv.dll, libpcre.dll 这3个库
                add_links("pixman-1", "fontconfig", "freetype", "png-9", "z-9", "harfbuzz", "graphite2", "intl", "bz2", "expat", "rpcrt4")
            else -- 32bit

            end

            -- gcc使用-Wl传递连接器参数，ld使用-Bdynamic强制连接动态库，-Bstatic强制连接静态库。所以部分静态
            -- -static-libgcc, -static-libstdc++, 分别用于链接对应的c/c++静态库
            -- 在--whole-archive 与 -Wl,--no-whole-archive直接添加需要静态链接的库, 此处当前为-lpthread,
            -- 但因为已加入就会有libpthread.a与libpthread.dll.a的重定义冲突, 所以去掉了
            add_ldflags("-static-libgcc -static-libstdc++ -Wl,-Bstatic,--whole-archive -lpthread -Wl,--no-whole-archive")
        elseif is_host("linux") then
            if is_arch("x86_64") then -- 64bit
                -- add_linkdirs("")
            else -- 32bit

            end
        end
    elseif is_mode("debug") then -- 调试时使用动态库, 较少链接时间
        if is_host("windows") then
            if is_arch("x86_64") then -- 64bit
                -- add_linkdirs("")
            else -- 32bit

            end
        elseif is_host("linux") then
            if is_host("windows") then
                -- add_linkdirs("")
            else -- 32bit

            end
        end
    end

-- define target
target("example1")

    -- set kind
    set_kind("binary")

    -- add files
    add_files("example1.cpp")

    -- add deps
    add_deps("cairowidget")

-- define target
target("example2")

    -- set kind
    set_kind("binary")

    -- add files
    add_files("example2.cpp")

    -- add deps
    -- add_deps("cairowidget")

    add_includedirs("./")
    add_files("cairoglwindow.cpp")
    add_files("caironanosvg.cpp")
    add_files("cairosurfacedevice.cpp")
    add_files("cairographicsdriver.cpp")
    add_files("cairowidget.cpp")

    set_languages("c++20")

    if is_host("windows") then -- 在Windows上编译

        -- add_includedirs("D:/OpenFree/FLTK-1.3.6/include/FL/images")
        add_includedirs("D:/OpenFree/FLTK-1.3.6/include")
        add_includedirs("D:/OpenFree/Cairo-1.16.0/include")
        add_includedirs("D:/OpenFree/Cairo-1.16.0/include/cairo")

        add_defines("WIN32", "USE_OPENGL32", "_LARGEFILE_SOURCE", "_LARGEFILE64_SOURCE", "_FILE_OFFSET_BITS=64")
        add_ldflags("-mwindows", "-lole32", "-luuid", "-lcomctl32", "-lsetupapi")
        -- add_ldflags("-lglu32", "-lopengl32", "-lz")

        if is_arch("x86_64") then
            add_linkdirs("D:/OpenFree/FLTK-1.3.6/lib")

            if is_mode("release") then
                add_linkdirs("D:/OpenFree/Cairo-1.16.0/lib") -- Cairo静态库目录
                add_linkdirs("D:/OpenFree/Cairo-1.16.0/lib/dep") --Cairo静态依赖库目录
            elseif is_mode("debug") then
                add_linkdirs("D:/OpenFree/Cairo-1.16.0/lib") -- Cairo动态库路目录, 不需要指定动态依赖库, 只要允许程序时能找到依赖的dll即可
                add_linkdirs("D:/OpenFree/Cairo-1.16.0/lib/dep") --Cairo静态依赖库目录
            end
        else
            add_linkdirs("D:/OpenFree/FLTK-1.3.6/lib/lib32")
        end

        -- add_links("ws2_32") -- windows.h与winsock2.h冲突, 暂时不解决
        -- add_links("wsock32") -- windows.h 包含winsock.h

        add_links("opengl32", "glu32")

    elseif is_host("linux") then -- 在Linux上编译

        add_includedirs("/usr/include/cairo")
        --add_includedirs("/Softwares/FLTK-1.4.x/include")
        add_includedirs("/usr/local/bin/FLTK-1.4.x/include")
        add_includedirs("/usr/include/freetype2", "/usr/include/libpng16", "/usr/include/harfbuzz", "/usr/include/glib-2.0", "/usr/lib/glib-2.0/include")

        add_defines("USE_OPENGL32", "_LARGEFILE_SOURCE", "_LARGEFILE64_SOURCE", "_FILE_OFFSET_BITS=64", "_THREAD_SAFE", "_REENTRANT")
        add_ldflags("-lXrender", "-lXcursor", "-lXfixes", "-lXext", "-lXft", "-lfontconfig", "-lXinerama", "-lpthread", "-ldl", "-lm", "-lX11")

        --add_linkdirs("/Softwares/FLTK-1.4.x/lib")
        add_linkdirs("/usr/local/bin/FLTK-1.4.x/lib")
        
        add_ldflags("-Wl,-rpath=/usr/local/lib")
        add_linkdirs("/usr/local/lib/")
        add_links("GL", "GLU")
    end

    add_links("fltk", "fltk_gl", "cairo")
    --add_ldflags("fltk_gl", "fltk_images", "fltk_forms", "fltk_png", "fltk_jpeg")
    -- add_links("fltk_cairo", "cairo") -- 取消此行注释以使用FLTK Cairo

    if is_mode("release") then -- 发布时使用静态库
        set_strip("all") -- 链接的时候，strip掉所有符号，包括调试符号

        if is_host("windows") then
            if is_arch("x86_64") then -- 64bit
                -- 下面这些库是Cairo的依赖库, rpcrt4是windows自动的dll，取消此行以使用Cairo
                -- 若没有这些库的话，可以下载emacs，emacs中带有这些库，libz(或zlib)改名为libz-9，libpng改名为libpng-9
                -- 在使用动态库时，还依赖libglib.dll, libiconv.dll, libpcre.dll 这3个库
                add_links("pixman-1", "fontconfig", "freetype", "png-9", "z-9", "harfbuzz", "graphite2", "intl", "bz2", "expat", "rpcrt4")
            else -- 32bit

            end

            -- gcc使用-Wl传递连接器参数，ld使用-Bdynamic强制连接动态库，-Bstatic强制连接静态库。所以部分静态
            -- -static-libgcc, -static-libstdc++, 分别用于链接对应的c/c++静态库
            -- 在--whole-archive 与 -Wl,--no-whole-archive直接添加需要静态链接的库, 此处当前为-lpthread,
            -- 但因为已加入就会有libpthread.a与libpthread.dll.a的重定义冲突, 所以去掉了
            add_ldflags("-static-libgcc -static-libstdc++ -Wl,-Bstatic,--whole-archive -lpthread -Wl,--no-whole-archive")
        elseif is_host("linux") then
            if is_arch("x86_64") then -- 64bit
                -- add_linkdirs("")
            else -- 32bit

            end
        end
    elseif is_mode("debug") then -- 调试时使用动态库, 较少链接时间
        if is_host("windows") then
            if is_arch("x86_64") then -- 64bit
                -- add_linkdirs("")
            else -- 32bit

            end
        elseif is_host("linux") then
            if is_host("windows") then
                -- add_linkdirs("")
            else -- 32bit

            end
        end
    end

-- define target
target("example3")

    -- set kind
    set_kind("binary")

    -- add files
    add_files("example3.cpp")

    -- add deps
    add_deps("cairowidget")

--
-- If you want to known more usage about xmake, please see https://xmake.io
--
-- ## FAQ
--
-- You can enter the project directory firstly before building project.
--
--   $ cd projectdir
--
-- 1. How to build project?
--
--   $ xmake
--
-- 2. How to configure project?
--
--   $ xmake f -p [macosx|linux|iphoneos ..] -a [x86_64|i386|arm64 ..] -m [debug|release]
--
-- 3. Where is the build output directory?
--
--   The default output directory is `./build` and you can configure the output directory.
--
--   $ xmake f -o outputdir
--   $ xmake
--
-- 4. How to run and debug target after building project?
--
--   $ xmake run [targetname]
--   $ xmake run -d [targetname]
--
-- 5. How to install target to the system directory or other output directory?
--
--   $ xmake install
--   $ xmake install -o installdir
--
-- 6. Add some frequently-used compilation flags in xmake.lua
--
-- @code
--    -- add debug and release modes
--    add_rules("mode.debug", "mode.release")
--
--    -- add macro defination
--    add_defines("NDEBUG", "_GNU_SOURCE=1")
--
--    -- set warning all as error
--    set_warnings("all", "error")
--
--    -- set language: c99, c++11
--    set_languages("c99", "c++11")
--
--    -- set optimization: none, faster, fastest, smallest
--    set_optimize("fastest")
--
--    -- add include search directories
--    add_includedirs("/usr/include", "/usr/local/include")
--
--    -- add link libraries and search directories
--    add_links("tbox")
--    add_linkdirs("/usr/local/lib", "/usr/lib")
--
--    -- add system link libraries
--    add_syslinks("z", "pthread")
--
--    -- add compilation and link flags
--    add_cxflags("-stdnolib", "-fno-strict-aliasing")
--    add_ldflags("-L/usr/local/lib", "-lpthread", {force = true})
--
-- @endcode
--

