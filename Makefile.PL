use ExtUtils::MakeMaker;

WriteMakefile(
   NAME         => "Data::Dump",
   VERSION_FROM => "Dump.pm",
   dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz'},
);
