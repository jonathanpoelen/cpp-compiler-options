includes'cpp'

jln_cxx_init_options({warnings='very_strict'})
jln_cxx_init_modes({
  debug={function() end},
  release={}
})

target("test")
  set_kind("binary")
  on_load(function(target)
    import'cpp.flags'
    flags.set_flags(target)
  end)
  add_files("test.cpp")
