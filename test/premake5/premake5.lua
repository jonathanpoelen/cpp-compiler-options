include'../../output/cpp/premake5'

workspace "HelloWorld"
   configurations { "Debug", "Release" }
   location "/tmp/premake"

project "HelloWorld"
   kind "ConsoleApp"
   language "C++"

   jln_newoptions({warnings='on'})
   options=jln_setoptions({sanitizers=true})
   printf("cxx:\n%s\nlink:\n%s",
          table.concat(options.buildoptions, '\n'),
          table.concat(options.linkoptions, '\n'))
   files { "test.cpp" }
