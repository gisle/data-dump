use ExtUtils::MakeMaker;

WriteMakefile(
   NAME         => "Data::Dump",
   VERSION_FROM => "lib/Data/Dump.pm",
   dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz'},
);
