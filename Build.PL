use Module::Build;
Module::Build->new
    ( module_name => 'HTML::WebDAO',
    license => 'perl',
   prereq => {
	      'FreezeThaw' => 0.43,
	      'MLDBM'	=> '0',
	     },
  script_files=>[qw!
    script/wd_cgi.pl
    script/wd_fcgi.fpl
    script/wd_shell.pl
  !],
    create_makefile_pl=>$ENV{DO_OUTCPAN} ? 'traditional':'passthrough'
    )->create_build_script;
