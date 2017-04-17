PROJECT	= erldog

DEPS = lhttpc jsx
dep_lhttpc = git git://github.com/SCDependencies/lhttpc SC-master
dep_jsx = git https://github.com/SCDependencies/jsx.git SC-master
include erlang.mk
