#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;

use Ubic::Service::Hypnotoad;

ok(1, 'Module loaded successfully');

my $h = Ubic::Service::Hypnotoad->new({
  bin => '/usr/bin/hypnotoad',
  app => 'script/test',
  cwd => '/home/my/app/'
});

is $h->{pid_file}, '/home/my/app/script/hypnotoad.pid';

$h = Ubic::Service::Hypnotoad->new({
  bin => '/usr/bin/hypnotoad',
  app => 'script/test',
  cwd => '/home/my/app',
  pid_file => '/path/to/pid/file'
});

is $h->{pid_file}, '/path/to/pid/file';

$h = Ubic::Service::Hypnotoad->new({
  bin => '/usr/bin/hypnotoad',
  app => '/home/my/app/script/test'
});

is $h->{pid_file}, '/home/my/app/script/hypnotoad.pid';

$h = Ubic::Service::Hypnotoad->new({
  bin => '/usr/bin/hypnotoad',
  app => '/home/my/app/script/test',
  cwd => '/home/my/app/'
});

is $h->{pid_file}, '/home/my/app/script/hypnotoad.pid';

done_testing;
