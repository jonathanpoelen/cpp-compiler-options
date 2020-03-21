include'../../output/cpp/premake5'

workspace "HelloWorld"
   configurations { "Debug", "Release" }
   location "/tmp/premake"

project "HelloWorld"
   kind "ConsoleApp"
   language "C++"

   jln_newoptions({warnings='on'})
   options=jln_setoptions({sanitizers=true})
   printf("cxx=%s\nlink=%s", options.buildoptions, options.linkoptions)
   files { "test.cpp" }
