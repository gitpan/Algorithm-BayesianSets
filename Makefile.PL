use inc::Module::Install;
name 'Algorithm-BayesianSets';
all_from 'lib/Algorithm/BayesianSets.pm';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
