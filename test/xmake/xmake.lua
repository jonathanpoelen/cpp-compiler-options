includes'cpp'

jln_cxx_init_options({warnings='very_strict'})

target("test")
  set_kind("binary")
  on_load(function(target)
    import'cpp.flags'
    flags.setoptions(target)
  end)
  add_files("test.cpp")
