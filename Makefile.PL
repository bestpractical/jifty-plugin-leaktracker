use inc::Module::Install 0.46;
name('Jifty-Plugin-LeakTracker');
version_from('lib/Jifty/Plugin/LeakTracker.pm');

requires('Jifty' => '0.90422');
requires('Devel::Events::Objects' => '0.02'); # Devel::Events::Handler::ObjectTracker Devel::Events::Generator::Objects

auto_install();
tests(qw( t/*/t/*.t ));

WriteAll;
