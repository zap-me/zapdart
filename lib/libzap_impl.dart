import 'dart:ffi';
import 'dart:typed_data';
import "dart:convert";
import 'package:flutter/foundation.dart';
import 'package:ffi/ffi.dart';
import 'package:zapdart/libzap.dart';

import 'dylib_utils.dart';

/// Copy a list of ints into the C memory
void copyInto(Pointer<Uint8> buf, int offset, Iterable<int> data) {
  assert(buf != nullptr);
  var n = 0;
  for (var byte in data) buf.elementAt(offset + n++).value = byte;
}

/// Read the buffer from C memory into Dart.
List<int> toIntList(Pointer<Uint8> buf, int len) {
  if (buf == nullptr) return [];
  return List<int>.generate(len, (i) => buf.elementAt(i).value);
}

extension BufferWranglingTx on Tx {
  static final textFieldSize = 1024;
  static final int64FieldSize = 8;
  static final totalSize =
      int64FieldSize + textFieldSize * 6 + int64FieldSize * 3;

  Pointer<Uint8> toBuffer() {
    var buf = calloc<Uint8>(totalSize);
    var offset = 0;
    var intList = new Uint8List(int64FieldSize);
    var intByteData = new ByteData.view(intList.buffer);

    // type field
    intByteData.setInt64(offset, type);
    copyInto(buf, offset, intList);
    offset += int64FieldSize;
    // id field
    copyInto(buf, offset, utf8.encode(id));
    offset += textFieldSize;
    // sender field
    copyInto(buf, offset, utf8.encode(sender));
    offset += textFieldSize;
    // recipient field
    copyInto(buf, offset, utf8.encode(recipient));
    offset += textFieldSize;
    // assetId field
    copyInto(buf, offset, utf8.encode(assetId));
    offset += textFieldSize;
    // feeAsset field
    copyInto(buf, offset, utf8.encode(feeAsset));
    offset += textFieldSize;
    // attachment field
    if (attachment != null) copyInto(buf, offset, utf8.encode(attachment!));
    offset += textFieldSize;
    // amount field
    intByteData.setInt64(0, amount);
    copyInto(buf, offset, intList);
    offset += int64FieldSize;
    // fee field
    intByteData.setInt64(0, fee);
    copyInto(buf, offset, intList);
    offset += int64FieldSize;
    // timestamp field
    intByteData.setInt64(0, timestamp);
    copyInto(buf, offset, intList);
    offset += int64FieldSize;

    return buf;
  }

  static Tx fromBuffer(Pointer<Uint8> buf) {
    var ints = toIntList(buf, totalSize);
    int offset = 0;

    var type = Int8List.fromList(ints)
        .buffer
        .asByteData()
        .getInt64(offset, Endian.little);
    offset += 8;
    var id = intListToString(ints, offset, textFieldSize);
    offset += textFieldSize;
    var sender = intListToString(ints, offset, textFieldSize);
    offset += textFieldSize;
    var recipient = intListToString(ints, offset, textFieldSize);
    offset += textFieldSize;
    var assetId = intListToString(ints, offset, textFieldSize);
    offset += textFieldSize;
    var feeAsset = intListToString(ints, offset, textFieldSize);
    offset += textFieldSize;
    var attachment = intListToString(ints, offset, textFieldSize);
    offset += textFieldSize;
    var amount = Int8List.fromList(ints)
        .buffer
        .asByteData()
        .getInt64(offset, Endian.little);
    offset += 8;
    var fee = Int8List.fromList(ints)
        .buffer
        .asByteData()
        .getInt64(offset, Endian.little);
    offset += 8;
    var timestamp = Int8List.fromList(ints)
        .buffer
        .asByteData()
        .getInt64(offset, Endian.little);
    offset += 8;

    return Tx(type, id, sender, recipient, assetId, feeAsset, attachment,
        amount, fee, timestamp);
  }

  static Iterable<Tx> fromBufferMulti(Pointer<Uint8> buf, int count) {
    return List<Tx>.generate(count, (index) {
      var offset = index * totalSize;
      return fromBuffer(buf.elementAt(offset));
    });
  }

  static Pointer<Uint8> allocateMem({int count = 1}) {
    return calloc<Uint8>(totalSize * count);
  }
}

extension BufferWranglingSpendTx on SpendTx {
  static final int32FieldSize = 4;
  static final dataFieldSize = 364;
  static final sigFieldSize = 64;
  static final totalSize =
      int32FieldSize + dataFieldSize + int32FieldSize + sigFieldSize;

  Pointer<Uint8> toBuffer() {
    var buf = calloc<Uint8>(totalSize);

    // success field
    var int32List = new Uint8List(int32FieldSize);
    var int32ByteData = new ByteData.view(int32List.buffer);
    int32ByteData.setInt32(0, 1);
    copyInto(buf, 0, int32List);
    // data field
    copyInto(buf, int32FieldSize, data);
    // data_size field
    int32ByteData.setInt32(0, data.length);
    copyInto(buf, int32FieldSize + dataFieldSize, int32List);
    // signature field
    copyInto(buf, int32FieldSize + dataFieldSize + int32FieldSize, signature);

    return buf;
  }

  static SpendTx fromBuffer(Pointer<Uint8> buf) {
    var ints = toIntList(buf, totalSize);

    var success =
        Int8List.fromList(ints).buffer.asByteData().getInt32(0, Endian.little);
    var dataSize = Int8List.fromList(ints)
        .buffer
        .asByteData()
        .getInt32(int32FieldSize + dataFieldSize, Endian.little);
    assert(dataSize >= 0 && dataSize <= dataFieldSize);
    var data = ints.skip(int32FieldSize).take(dataSize);
    var sig = ints
        .skip(int32FieldSize + dataFieldSize + int32FieldSize)
        .take(sigFieldSize);

    return SpendTx(success != 0, data, sig);
  }

  static Pointer<Uint8> allocateMem() {
    return calloc<Uint8>(totalSize);
  }
}

extension BufferWranglingSig on Signature {
  static final int32FieldSize = 4;
  static final sigFieldSize = 64;
  static final totalSize = int32FieldSize + sigFieldSize;

  static Signature fromBuffer(Pointer<Uint8> buf) {
    var ints = toIntList(buf, totalSize);

    var success =
        Int8List.fromList(ints).buffer.asByteData().getInt32(0, Endian.little);
    var sig = ints.skip(int32FieldSize).take(sigFieldSize);

    return Signature(success != 0, sig);
  }

  static Pointer<Uint8> allocateMem() {
    return calloc<Uint8>(totalSize);
  }
}

//
// native libzap definitions
//

/*
class IntResultNative extends Struct {
  @Int32()
  int success;

  @Int64()
  int value;

  factory IntResultNative(bool success, int value) {
    return calloc<IntResultNative>().ref
      ..success = (success ? 1 : 0)
      ..value = value;
  }
}
*/

/* c def
#define MAX_TXFIELD 1024
struct waves_payment_request_t
{
  char address[MAX_TXFIELD];
  char asset_id[MAX_TXFIELD];
  char attachment[MAX_TXFIELD];
  uint64_t amount;
};
class WavesPaymentRequestNative extends Struct {
}
*/

typedef LzapVersionNative = Int32 Function();
typedef LzapVersion = int Function();

typedef LzapNodeGet = Pointer<Utf8> Function();
typedef LzapNodeSetNative = Int8 Function(Pointer<Utf8> url);
typedef LzapNodeSet = int Function(Pointer<Utf8> url);
typedef LzapNetworkGetNative = Int8 Function();
typedef LzapNetworkGet = int Function();
typedef LzapNetworkSetNative = Int8 Function(Int8 networkByte);
typedef LzapNetworkSet = int Function(int networkByte);
typedef LzapAssetIdGet = Pointer<Utf8> Function();
typedef LzapAssetIdSetNative = Int8 Function(Pointer<Utf8> assetId);
typedef LzapAssetIdSet = int Function(Pointer<Utf8> assetId);

typedef LzapMnemonicCreateNative = Int8 Function(
    Pointer<Utf8> output, Int32 size);
typedef LzapMnemonicCreate = int Function(Pointer<Utf8> output, int size);
typedef LzapMnemonicWordlist = Pointer<Pointer<Utf8>> Function();

typedef LzapMnemonicCheckNative = Int8 Function(Pointer<Utf8> mnemonic);
typedef LzapMnemonicCheck = int Function(Pointer<Utf8> mnemonic);

//TODO: this function does not actually return anything, but dart:ffi does not seem to handle void functions yet
typedef LzapSeedAddressNative = Int32 Function(
    Pointer<Utf8> seed, Pointer<Utf8> output);
typedef LzapSeedAddress = int Function(
    Pointer<Utf8> seed, Pointer<Utf8> output);

typedef LzapAddressCheckNative = IntResult Function(Pointer<Utf8> address);
//TODO: ns version
typedef LzapAddressCheckNsNative = Int8 Function(Pointer<Utf8> address);
typedef LzapAddressCheckNs = int Function(Pointer<Utf8> address);

//TODO: ns version
typedef LzapAddressBalanceNsNative = Int8 Function(
    Pointer<Utf8> address, Pointer<Int64> balanceOut);
typedef LzapAddressBalanceNs = int Function(
    Pointer<Utf8> address, Pointer<Int64> balanceOut);

//TODO: ns version of transaction list
typedef LzapAddressTransactions2NsNative = Int8 Function(
    Pointer<Utf8> address,
    Pointer<Uint8> txs,
    Int32 count,
    Pointer<Utf8> after,
    Pointer<Int64> countOut);
typedef LzapAddressTransactions2Ns = int Function(
    Pointer<Utf8> address,
    Pointer<Uint8> txs,
    int count,
    Pointer<Utf8> after,
    Pointer<Int64> countOut);

typedef LzapTransactionFeeNsNative = Int8 Function(Pointer<Int64> feeOut);
typedef LzapTransactionFeeNs = int Function(Pointer<Int64> feeOut);

//TODO: this function does not actually return anything, but dart:ffi does not seem to handle void functions yet
typedef LzapTransactionCreateNsNative = Int32 Function(
    Pointer<Utf8> seed,
    Pointer<Utf8> recipient,
    Int64 amount,
    Int64 fee,
    Pointer<Utf8> attachment,
    Pointer<Uint8> spendTxOut);
typedef LzapTransactionCreateNs = int Function(
    Pointer<Utf8> seed,
    Pointer<Utf8> recipient,
    int amount,
    int fee,
    Pointer<Utf8> attachment,
    Pointer<Uint8> spendTxOut);

//TODO: ns version of transaction broadcast!!!
typedef LzapTransactionBroadcastNsNative = Int32 Function(
    Pointer<Uint8> spendTx, Pointer<Uint8> broadcastTxOut);
typedef LzapTransactionBroadcastNs = int Function(
    Pointer<Uint8> spendTx, Pointer<Uint8> broadcastTxOut);

//TODO: ns version of transaction broadcast!!!
typedef LzapMessageSignNsNative = Int32 Function(Pointer<Utf8> seed,
    Pointer<Uint8> message, Int32 messageSize, Pointer<Uint8> signatureOut);
typedef LzapMessageSignNs = int Function(Pointer<Utf8> seed,
    Pointer<Uint8> message, int messageSize, Pointer<Uint8> signatureOut);

//
// helper functions
//

String intListToString(Iterable<int> lst, int offset, int count) {
  lst = lst.skip(offset).take(count);
  int len = 0;
  while (lst.elementAt(len) != 0) len++;
  return Utf8Decoder().convert(lst.take(len).toList());
}

IntResult addressBalanceFromIsolate(String address) {
  // as we are running this in an isolate we need to reinit a LibZap instance
  // to get the function pointer as closures can not be passed to isolates
  var libzap = LibZapImpl();

  var addrC = address.toNativeUtf8();
  var balanceP = calloc<Int64>();
  var res = libzap.lzapAddressBalance(addrC, balanceP) != 0;
  int balance = balanceP.value;
  calloc.free(balanceP);
  calloc.free(addrC);
  return IntResult(res, balance);
}

AddrTxsResult addressTransactionsFromIsolate(AddrTxsRequest req) {
  // as we are running this in an isolate we need to reinit a LibZap instance
  // to get the function pointer as closures can not be passed to isolates
  var libzap = LibZapImpl();

  var addrC = req.address.toNativeUtf8();
  var txsC = BufferWranglingTx.allocateMem(count: req.count);
  Pointer<Utf8> afterC = nullptr;
  if (req.after != null) afterC = req.after!.toNativeUtf8();
  var countOutP = calloc<Int64>();
  var res = libzap.lzapAddressTransactions(
          addrC, txsC, req.count, afterC, countOutP) !=
      0;
  Iterable<Tx> txs = [];
  if (res) {
    int count = countOutP.value;
    txs = BufferWranglingTx.fromBufferMulti(txsC, count);
  }
  calloc.free(countOutP);
  if (req.after != null) calloc.free(afterC);
  calloc.free(txsC);
  calloc.free(addrC);
  return AddrTxsResult(res, txs);
}

IntResult transactionFeeFromIsolate(int dummy) {
  // as we are running this in an isolate we need to reinit a LibZap instance
  // to get the function pointer as closures can not be passed to isolates
  var libzap = LibZapImpl();

  var feeP = calloc<Int64>();
  var res = libzap.lzapTransactionFee(feeP) != 0;
  int fee = feeP.value;
  calloc.free(feeP);
  return IntResult(res, fee);
}

Tx? transactionBroadcastFromIsolate(SpendTx spendTx) {
  // as we are running this in an isolate we need to reinit a LibZap instance
  // to get the function pointer as closures can not be passed to isolates
  var libzap = LibZapImpl();

  var spendTxC = spendTx.toBuffer();
  var txC = BufferWranglingTx.allocateMem();
  var result = libzap.lzapTransactionBroadcast(spendTxC, txC);
  Tx? tx;
  if (result != 0) tx = BufferWranglingTx.fromBuffer(txC);
  calloc.free(txC);
  calloc.free(spendTxC);
  return tx;
}

LibZap getLibZap() => LibZapImpl();

//
// LibZap class
//

class LibZapImpl implements LibZap {
  LibZapImpl() {
    libzap = dlopenPlatformSpecific("zap");
    lzapVersion = libzap
        .lookup<NativeFunction<LzapVersionNative>>("lzap_version")
        .asFunction();
    lzapNodeGet = libzap
        .lookup<NativeFunction<LzapNodeGet>>("lzap_node_get")
        .asFunction();
    lzapNodeSet = libzap
        .lookup<NativeFunction<LzapNodeSetNative>>("lzap_node_set")
        .asFunction();
    lzapNetworkGet = libzap
        .lookup<NativeFunction<LzapNetworkGetNative>>("lzap_network_get")
        .asFunction();
    lzapNetworkSet = libzap
        .lookup<NativeFunction<LzapNetworkSetNative>>("lzap_network_set")
        .asFunction();
    lzapAssetIdGet = libzap
        .lookup<NativeFunction<LzapAssetIdGet>>("lzap_asset_id_get")
        .asFunction();
    lzapAssetIdSet = libzap
        .lookup<NativeFunction<LzapAssetIdSetNative>>("lzap_asset_id_set")
        .asFunction();
    lzapMnemonicCreate = libzap
        .lookup<NativeFunction<LzapMnemonicCreateNative>>(
            "lzap_mnemonic_create")
        .asFunction();
    lzapMnemonicCheck = libzap
        .lookup<NativeFunction<LzapMnemonicCheckNative>>("lzap_mnemonic_check")
        .asFunction();
    lzapMnemonicWordlist = libzap
        .lookup<NativeFunction<LzapMnemonicWordlist>>("lzap_mnemonic_wordlist")
        .asFunction();

    lzapSeedAddress = libzap
        .lookup<NativeFunction<LzapSeedAddressNative>>("lzap_seed_address")
        .asFunction();
    lzapAddressCheck = libzap
        .lookup<NativeFunction<LzapAddressCheckNsNative>>(
            "lzap_address_check_ns")
        .asFunction();
    lzapAddressBalance = libzap
        .lookup<NativeFunction<LzapAddressBalanceNsNative>>(
            "lzap_address_balance_ns")
        .asFunction();
    lzapAddressTransactions = libzap
        .lookup<NativeFunction<LzapAddressTransactions2NsNative>>(
            "lzap_address_transactions2_ns")
        .asFunction();
    lzapTransactionFee = libzap
        .lookup<NativeFunction<LzapTransactionFeeNsNative>>(
            "lzap_transaction_fee_ns")
        .asFunction();
    lzapTransactionCreate = libzap
        .lookup<NativeFunction<LzapTransactionCreateNsNative>>(
            "lzap_transaction_create_ns")
        .asFunction();
    lzapTransactionBroadcast = libzap
        .lookup<NativeFunction<LzapTransactionBroadcastNsNative>>(
            "lzap_transaction_broadcast_ns")
        .asFunction();
    lzapMessageSign = libzap
        .lookup<NativeFunction<LzapMessageSignNsNative>>("lzap_message_sign_ns")
        .asFunction();
  }

  late DynamicLibrary libzap;
  late LzapVersion lzapVersion;
  late LzapNodeGet lzapNodeGet;
  late LzapNodeSet lzapNodeSet;
  late LzapNetworkGet lzapNetworkGet;
  late LzapNetworkSet lzapNetworkSet;
  late LzapAssetIdGet lzapAssetIdGet;
  late LzapAssetIdSet lzapAssetIdSet;
  late LzapMnemonicCreate lzapMnemonicCreate;
  late LzapMnemonicCheck lzapMnemonicCheck;
  late LzapMnemonicWordlist lzapMnemonicWordlist;
  late LzapSeedAddress lzapSeedAddress;
  late LzapAddressCheckNs lzapAddressCheck;
  late LzapAddressBalanceNs lzapAddressBalance;
  late LzapAddressTransactions2Ns lzapAddressTransactions;
  late LzapTransactionFeeNs lzapTransactionFee;
  late LzapTransactionCreateNs lzapTransactionCreate;
  late LzapTransactionBroadcastNs lzapTransactionBroadcast;
  late LzapMessageSignNs lzapMessageSign;

  //
  // native libzap wrapper functions
  //

  int version() {
    return lzapVersion();
  }

  String nodeGet() {
    return lzapNodeGet().toDartString();
  }

  bool nodeSet(String url) {
    var urlC = url.toNativeUtf8();
    var res = lzapNodeSet(urlC) != 0;
    calloc.free(urlC);
    return res;
  }

  bool testnetGet() {
    var networkByte = String.fromCharCode(lzapNetworkGet());
    if (networkByte == 'T')
      return true;
    else if (networkByte == 'W')
      return false;
    else
      throw new FormatException("network byte not recognised");
  }

  bool testnetSet(bool value) {
    String networkByte;
    if (value)
      networkByte = 'T';
    else
      networkByte = 'W';
    int char = networkByte.codeUnitAt(0);
    return lzapNetworkSet(char) != 0;
  }

  String assetIdGet() {
    return lzapAssetIdGet().toDartString();
  }

  void assetIdSet(String value) {
    var valueC = value.toNativeUtf8();
    lzapAssetIdSet(valueC);
    calloc.free(valueC);
  }

  bool networkParamsSet(String? assetIdMainnet, String? assetIdTestnet,
      String? nodeUrlMainnet, String? nodeUrlTestnet, bool testnet) {
    var result = true;
    print('testnetSet($testnet)..');
    if (!testnetSet(testnet)) result = false;
    if (testnet && assetIdTestnet != null) {
      print('assetIdSet("$assetIdTestnet")..');
      assetIdSet(assetIdTestnet);
    } else if (!testnet && assetIdMainnet != null) {
      print('assetIdSet("$assetIdMainnet")..');
      assetIdSet(assetIdMainnet);
    } else {
      print('assetIdSet("")..');
      assetIdSet('');
    }
    if (testnet && nodeUrlTestnet != null) {
      print('nodeSet("$nodeUrlTestnet")..');
      if (!nodeSet(nodeUrlTestnet)) result = false;
    } else if (!testnet && nodeUrlMainnet != null) {
      print('nodeSet("$nodeUrlMainnet")..');
      if (!nodeSet(nodeUrlMainnet)) result = false;
    } else {
      print('nodeSet("")..');
      if (!nodeSet('')) result = false;
    }
    print('networkParamsSet = $result');
    return result;
  }

  String? mnemonicCreate() {
    var mem = "0" * 1024;
    var outputC = mem.toNativeUtf8();
    var res = lzapMnemonicCreate(outputC, 1024);
    var mnemonic = outputC.toDartString();
    calloc.free(outputC);
    if (res != 0) return mnemonic;
    return null;
  }

  bool mnemonicCheck(String mnemonic) {
    var mnemonicC = mnemonic.toNativeUtf8();
    var res = lzapMnemonicCheck(mnemonicC) != 0;
    calloc.free(mnemonicC);
    return res;
  }

  List<String> mnemonicWordlist() {
    var wordlist = <String>[];
    var wordC = lzapMnemonicWordlist();
    while (wordC.value.address != 0) {
      wordlist.add(wordC.value.toDartString());
      wordC = wordC.elementAt(1);
    }
    return wordlist;
  }

  String seedAddress(String seed) {
    var seedC = seed.toNativeUtf8();
    var mem = "0" * 1024;
    var outputC = mem.toNativeUtf8();
    lzapSeedAddress(seedC, outputC);
    var address = outputC.toDartString();
    calloc.free(outputC);
    calloc.free(seedC);
    return address;
  }

  bool addressCheck(String address) {
    var addrC = address.toNativeUtf8();
    var res = lzapAddressCheck(addrC) != 0;
    calloc.free(addrC);
    return res;
  }

  Future<IntResult> addressBalance(String address) async {
    return compute(addressBalanceFromIsolate, address);
  }

  Future<AddrTxsResult> addressTransactions(
      String address, int count, String? after) async {
    return compute(
        addressTransactionsFromIsolate, AddrTxsRequest(address, count, after));
  }

  Future<IntResult> transactionFee() async {
    return compute(transactionFeeFromIsolate, 0);
  }

  SpendTx transactionCreate(
      String seed, String recipient, int amount, int fee, String? attachment) {
    var seedC = seed.toNativeUtf8();
    var recipientC = recipient.toNativeUtf8();
    if (attachment == null) attachment = "";
    var attachmentC = attachment.toNativeUtf8();
    var outputC = BufferWranglingSpendTx.allocateMem();
    lzapTransactionCreate(seedC, recipientC, amount, fee, attachmentC, outputC);
    var spendTx = BufferWranglingSpendTx.fromBuffer(outputC);
    calloc.free(outputC);
    calloc.free(attachmentC);
    calloc.free(recipientC);
    calloc.free(seedC);
    return spendTx;
  }

  Future<Tx?> transactionBroadcast(SpendTx spendTx) async {
    return compute(transactionBroadcastFromIsolate, spendTx);
  }

  Signature messageSign(String seed, Iterable<int> message) {
    var seedC = seed.toNativeUtf8();
    var messageC = calloc<Uint8>(message.length);
    copyInto(messageC, 0, message);
    var outputC = BufferWranglingSig.allocateMem();
    lzapMessageSign(seedC, messageC, message.length, outputC);
    var signature = BufferWranglingSig.fromBuffer(outputC);
    calloc.free(outputC);
    calloc.free(messageC);
    calloc.free(seedC);
    return signature;
  }
}
