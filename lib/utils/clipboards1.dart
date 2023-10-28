import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef OpenClipboardC = Int32 Function(Pointer<Void> hWndNewOwner);
typedef OpenClipboardDart = int Function(Pointer<Void> hWndNewOwner);

typedef EmptyClipboardC = Int32 Function();
typedef EmptyClipboardDart = int Function();

typedef SetClipboardDataC = Pointer<Void> Function(Uint32 uFormat, Pointer<Uint8> hMem);
typedef SetClipboardDataDart = Pointer<Void> Function(int uFormat, Pointer<Uint8> hMem);

class Clipboards {
  static final Clipboards _instance = Clipboards._();

  late DynamicLibrary user32;

  late OpenClipboardDart openClipboardP;

  late EmptyClipboardDart emptyClipboardP;

  late SetClipboardDataDart setClipboardDataP;
  factory Clipboards() => _instance;

  Clipboards._() {
    user32 = DynamicLibrary.open('user32.dll');
    openClipboardP = user32.lookupFunction<OpenClipboardC, OpenClipboardDart>('OpenClipboard');
    emptyClipboardP = user32.lookupFunction<EmptyClipboardC, EmptyClipboardDart>('EmptyClipboard');
    setClipboardDataP = user32.lookupFunction<SetClipboardDataC, SetClipboardDataDart>('SetClipboardData');
  }

  copy(File file) {
    final bytes = file.readAsBytesSync();
    final pointer = calloc.allocate<Uint8>(bytes.length);
    final list = pointer.asTypedList(bytes.length);
    list.setAll(0, bytes);

    if (openClipboardP(nullptr) != 0) {
      // if (emptyClipboardP() != 0) {
      setClipboardDataP(2 /* CF_BITMAP */, pointer);
      // }
      openClipboardP(nullptr);
    }
  }
}
