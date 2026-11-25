import 'dart:js_interop';

@JS('mettleBootComplete')
external void mettleBootComplete();

void signalBootComplete() => mettleBootComplete();
