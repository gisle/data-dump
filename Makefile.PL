use ExtUtils::MakeMaker;

WriteMakefile(
   NAME         => "Data::Dump",
   VERSION_FROM => "Dump.pm",
   PREREQ_PM    => { 
                      "Statistics::Descriptive" => 2,
                   },
   dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz'},
);
