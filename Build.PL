use Module::Build;
Module::Build->new
    ( module_name => 'HTML::WebDAO',
    license => 'perl',
   prereq => {
	      'FreezeThaw' => 0.43,
	      'MLDBM'	=> '0',
	     },
    create_makefile_pl=>$ENV{DO_OUTCPAN} ? 'traditional':'passthrough'
    )->create_build_script;
