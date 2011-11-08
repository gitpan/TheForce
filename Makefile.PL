use inc::Module::Install;

name     'TheForce';
all_from 'lib/TheForce.pm';
author   q{Brad Haywood <brad@geeksware.net>};
license  'perl';

build_requires 'Test::More';
requires 'Module::Finder';

auto_install;

WriteAll;

