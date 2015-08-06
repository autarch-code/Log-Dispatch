use strict;
use warnings;

use Test::More 0.88;

use Test::Requires {
    'Sys::Syslog' => '0.28',
    'threads'     => '0',
};

use Log::Dispatch;
use Log::Dispatch::Syslog;
use threads;
use threads::shared;

no warnings 'redefine', 'once';

my @sock;
local *Sys::Syslog::setlogsock = sub { @sock = @_ };

local *Sys::Syslog::openlog  = sub { return 1 };
local *Sys::Syslog::closelog = sub { return 1 };

my @log;
local *Sys::Syslog::syslog = sub { push @log, [@_] };

SKIP:
{
    @log = ();

    my $dispatch = Log::Dispatch->new;
    $dispatch->add(
        Log::Dispatch::Syslog->new(
            name      => 'syslog',
            min_level => 'debug',
            lock      => 1,
        )
    );

    $dispatch->info('Foo thread');

    is_deeply(
        \@log,
        [ [ 'INFO', 'Foo thread' ] ],
        'passed message to syslog (with thread lock)'
    );
}

done_testing();
