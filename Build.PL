use Module::Build;
Module::Build->new
    ( module_name => 'WebDAO',
    license => 'perl',
   prereq => {
	      'XML::Flow'=>'0.86',
	      'DateTime'=> 0.37,
	      'DateTime::Format::HTTP'=>0.37,
	      'Encode'=> 0,
	      'Getopt::Long'=>2.35,
	      'FCGI'=>0.67,
	      'Test::Class'=>0,
	      'URI'=>1.36,
	       },
  script_files=>[qw!
    script/wd_cgi.pl
    script/wd_fcgi.fpl
    script/wd_shell.pl
  !],
    create_makefile_pl=>$ENV{DO_OUTCPAN} ? 'traditional':'passthrough'
    )->create_build_script;
