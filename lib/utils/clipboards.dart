import 'dart:ffi' as ffi;
import 'dart:io' show File, Platform;
import 'package:ffi/ffi.dart';

typedef OpenClipboardC = ffi.IntPtr Function(ffi.IntPtr hWndNewOwner);
typedef OpenClipboardDart = int Function(int hWndNewOwner);

typedef EmptyClipboardC = ffi.IntPtr Function();
typedef EmptyClipboardDart = int Function();

typedef SetClipboardDataC = ffi.IntPtr Function(ffi.Uint32 uFormat, ffi.IntPtr hMem);
typedef SetClipboardDataDart = int Function(int uFormat, int hMem);

typedef CloseClipboardC = ffi.IntPtr Function();
typedef CloseClipboardDart = int Function();

class Clipboards {
  static final Clipboards _instance = Clipboards._();

  late ffi.DynamicLibrary _user32;

  late OpenClipboardDart _openClipboard;

  late EmptyClipboardDart _emptyClipboard;

  late SetClipboardDataDart _setClipboardData;

  late CloseClipboardDart _closeClipboard;

  factory Clipboards() => _instance;

  Clipboards._() {
    _user32 = ffi.DynamicLibrary.open('user32.dll');
    _openClipboard = _user32.lookupFunction<OpenClipboardC, OpenClipboardDart>('OpenClipboard');
    _emptyClipboard = _user32.lookupFunction<EmptyClipboardC, EmptyClipboardDart>('EmptyClipboard');
    _setClipboardData = _user32.lookupFunction<SetClipboardDataC, SetClipboardDataDart>('SetClipboardData');
    _closeClipboard = _user32.lookupFunction<CloseClipboardC, CloseClipboardDart>('CloseClipboard');
  }

  copy(File file) {
    final bytes = file.readAsBytesSync();
    final hMem = calloc.allocate<ffi.Uint8>(bytes.length);
    final memData = hMem.asTypedList(bytes.length);
    memData.setAll(0, bytes);

    if (_openClipboard(ffi.nullptr.address) == 0) {
      print('fail to open clipboard');
    }

    if (_emptyClipboard() == 0) {
      print('fail to empty clipboard');
    }

    print(_setClipboardData(8, hMem.address));

    if (_closeClipboard() == 0) {
      print('fail to close clipboard');
    }
    calloc.free(hMem);
  }
}
