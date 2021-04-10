import 'dart:ffi';
import 'dart:typed_data';
import "dart:convert";
import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';
import 'package:ffi/ffi.dart';

import 'dylib_utils.dart';

/// Copy a list of ints into the C memory
void copyInto(Pointer<Uint8> buf, int offset, Iterable<int> data) {
  assert(buf != nullptr);
  var n = 0;
  for (var byte in data)
    buf.elementAt(offset + n++).value = byte;
}

/// Read the buffer from C memory into Dart.
List<int> toIntList(Pointer<Uint8> buf, int len) {
  if (buf == nullptr) return null;
  return List<int>.generate(len, (i) => buf.elementAt(i).value);
}

class IntResult {
  bool success;
  int value;
  IntResult(this.success, this.value);
}

class Tx {
  static final textFieldSize = 1024;
  static final int64FieldSize = 8;
  static final totalSize = int64FieldSize + textFieldSize * 6 + int64FieldSize * 3;

  int type;
  String id;
  String sender;
  String recipient;
  String assetId;
  String feeAsset;
  String attachment;
  int amount;
  int fee;
  int timestamp;

  Tx(this.type, this.id, this.sender, this.recipient, this.assetId, this.feeAsset, this.attachment, this.amount, this.fee, this.timestamp);

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
    copyInto(buf, offset, utf8.encode(attachment));
    offset += textFieldSize;
    // amount field
    intByteData.setInt64(0, amount);
    copyInto(buf, offset, intList);
    offset += int64FieldSize;
    // amount field
    intByteData.setInt64(0, fee);
    copyInto(buf, offset, intList);
    offset += int64FieldSize;
    // amount field
    intByteData.setInt64(0, timestamp);
    copyInto(buf, offset, intList);
    offset += int64FieldSize;

    return buf;
  }

  static Tx fromBuffer(Pointer<Uint8> buf) {
    var ints = toIntList(buf, totalSize);
    int offset = 0;

    var type = Int8List.fromList(ints).buffer.asByteData().getInt64(offset, Endian.little);
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
    var amount = Int8List.fromList(ints).buffer.asByteData().getInt64(offset, Endian.little);
    offset += 8;
    var fee = Int8List.fromList(ints).buffer.asByteData().getInt64(offset, Endian.little);
    offset += 8;
    var timestamp = Int8List.fromList(ints).buffer.asByteData().getInt64(offset, Endian.little);
    offset += 8;

    return Tx(type, id, sender, recipient, assetId, feeAsset, attachment, amount, fee, timestamp);
  }

  static Iterable<Tx> fromBufferMulti(Pointer<Uint8> buf, int count) {
    return List<Tx>.generate(count, (index) {
      var offset = index * totalSize;
      return fromBuffer(buf.elementAt(offset));
    });
  }

  static Pointer<Uint8> allocateMem({int count=1}) {
    return calloc<Uint8>(totalSize * count);
  }

  Map<String, dynamic> toJson() =>
      {
        'type': type,
        'id': id,
        'sender': sender,
        'recipient': recipient,
        'assetId': assetId,
        'feeAsset': feeAsset,
        'attachment': attachment,
        'amount': amount,
        'fee': fee,
        'timestamp': timestamp
      };
}

class SpendTx {
  static final int32FieldSize = 4;
  static final dataFieldSize = 364;
  static final sigFieldSize = 64;
  static final totalSize = int32FieldSize + dataFieldSize + int32FieldSize + sigFieldSize;

  bool success;
  Iterable<int> data;
  Iterable<int> signature;

  SpendTx(this.success, this.data, this.signature);

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

    var success = Int8List.fromList(ints).buffer.asByteData().getInt32(0, Endian.little);
    var dataSize = Int8List.fromList(ints).buffer.asByteData().getInt32(int32FieldSize + dataFieldSize, Endian.little);
    assert(dataSize >= 0 && dataSize <= dataFieldSize);
    var data = ints.skip(int32FieldSize).take(dataSize);
    var sig = ints.skip(int32FieldSize + dataFieldSize + int32FieldSize).take(sigFieldSize);

    return SpendTx(success != 0, data, sig);
  }

  static Pointer<Uint8> allocateMem() {
    return calloc<Uint8>(totalSize);
  }
}

class Signature {
  static final int32FieldSize = 4;
  static final sigFieldSize = 64;
  static final totalSize = int32FieldSize + sigFieldSize;
  
  bool success;
  Iterable<int> signature;

  Signature(this.success, this.signature);

  static Signature fromBuffer(Pointer<Uint8> buf) {
    var ints = toIntList(buf, totalSize);

    var success = Int8List.fromList(ints).buffer.asByteData().getInt32(0, Endian.little);
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

typedef lzap_version_native_t = Int32 Function();
typedef lzap_version_t = int Function();

typedef lzap_node_get_t = Pointer<Utf8> Function();
typedef lzap_node_set_native_t = Int8 Function(Pointer<Utf8> url);
typedef lzap_node_set_t = int Function(Pointer<Utf8> url);
typedef lzap_network_get_native_t = Int8 Function();
typedef lzap_network_get_t = int Function();
typedef lzap_network_set_native_t = Int8 Function(Int8 networkByte);
typedef lzap_network_set_t = int Function(int networkByte);
typedef lzap_asset_id_get_t = Pointer<Utf8> Function();
typedef lzap_asset_id_set_native_t = Int8 Function(Pointer<Utf8> assetId);
typedef lzap_asset_id_set_t = int Function(Pointer<Utf8> assetId);

typedef lzap_mnemonic_create_native_t = Int8 Function(Pointer<Utf8> output, Int32 size);
typedef lzap_mnemonic_create_t = int Function(Pointer<Utf8> output, int size);
typedef lzap_mnemonic_wordlist_t = Pointer<Pointer<Utf8>> Function();

typedef lzap_mnemonic_check_native_t = Int8 Function(Pointer<Utf8> mnemonic);
typedef lzap_mnemonic_check_t = int Function(Pointer<Utf8> mnemonic);

//TODO: this function does not actually return anything, but dart:ffi does not seem to handle void functions yet
typedef lzap_seed_address_native_t = Int32 Function(Pointer<Utf8> seed, Pointer<Utf8> output);
typedef lzap_seed_address_t = int Function(Pointer<Utf8> seed, Pointer<Utf8> output);

typedef lzap_address_check_native_t = IntResult Function(Pointer<Utf8> address);
//TODO: ns version
typedef lzap_address_check_ns_native_t = Int8 Function(Pointer<Utf8> address);
typedef lzap_address_check_ns_t = int Function(Pointer<Utf8> address);

//TODO: ns version
typedef lzap_address_balance_ns_native_t = Int8 Function(Pointer<Utf8> address, Pointer<Int64> balanceOut);
typedef lzap_address_balance_ns_t = int Function(Pointer<Utf8> address, Pointer<Int64> balanceOut);

//TODO: ns version of transaction list
typedef lzap_address_transactions2_ns_native_t = Int8 Function(Pointer<Utf8> address, Pointer<Uint8> txs, Int32 count, Pointer<Utf8> after, Pointer<Int64> countOut);
typedef lzap_address_transactions2_ns_t = int Function(Pointer<Utf8> address, Pointer<Uint8> txs, int count, Pointer<Utf8> after, Pointer<Int64> countOut);

typedef lzap_transaction_fee_ns_native_t = Int8 Function(Pointer<Int64> feeOut);
typedef lzap_transaction_Fee_ns_t = int Function(Pointer<Int64> feeOut);

//TODO: this function does not actually return anything, but dart:ffi does not seem to handle void functions yet
typedef lzap_transaction_create_ns_native_t = Int32 Function(Pointer<Utf8> seed, Pointer<Utf8> recipient, Int64 amount, Int64 fee, Pointer<Utf8> attachment, Pointer<Uint8> spendTxOut);
typedef lzap_transaction_create_ns_t = int Function(Pointer<Utf8> seed, Pointer<Utf8> recipient, int amount, int fee, Pointer<Utf8> attachment, Pointer<Uint8> spendTxOut);

//TODO: ns version of transaction broadcast!!!
typedef lzap_transaction_broadcast_ns_native_t = Int32 Function(Pointer<Uint8> spendTx, Pointer<Uint8> broadcastTxOut);
typedef lzap_transaction_broadcast_ns_t = int Function(Pointer<Uint8> spendTx, Pointer<Uint8> broadcastTxOut);

//TODO: ns version of transaction broadcast!!!
typedef lzap_message_sign_ns_native_t = Int32 Function(Pointer<Utf8> seed, Pointer<Uint8> message, Int32 messageSize, Pointer<Uint8> signatureOut);
typedef lzap_message_sign_ns_t = int Function(Pointer<Utf8> seed, Pointer<Uint8> message, int messageSize, Pointer<Uint8> signatureOut);

//
// helper functions
//

String intListToString(Iterable<int> lst, int offset, int count) {
  lst = lst.skip(offset).take(count);
  int len = 0;
  while (lst.elementAt(len) != 0)
    len++;
  return Utf8Decoder().convert(lst.take(len).toList());
}

IntResult addressBalanceFromIsolate(String address) {
  // as we are running this in an isolate we need to reinit a LibZap instance
  // to get the function pointer as closures can not be passed to isolates
  var libzap = LibZap();

  var addrC = address.toNativeUtf8();
  var balanceP = calloc<Int64>();
  var res = libzap.lzapAddressBalance(addrC, balanceP) != 0;
  int balance = balanceP.value;
  calloc.free(balanceP);
  calloc.free(addrC);
  return IntResult(res, balance);
}

class AddrTxsRequest {
  String address;
  int count;
  String after;
  AddrTxsRequest(this.address, this.count, this.after);
}
Iterable<Tx> addressTransactionsFromIsolate(AddrTxsRequest req) {
  // as we are running this in an isolate we need to reinit a LibZap instance
  // to get the function pointer as closures can not be passed to isolates
  var libzap = LibZap();

  var addrC = req.address.toNativeUtf8();
  var txsC = Tx.allocateMem(count: req.count);
  Pointer afterC = nullptr;
  if (req.after != null)
    afterC = req.after.toNativeUtf8();
  var countOutP = calloc<Int64>();
  var res = libzap.lzapAddressTransactions(addrC, txsC, req.count, afterC.cast<Utf8>(), countOutP) != 0;
  Iterable<Tx> txs;
  if (res) {
    int count = countOutP.value;
    txs = Tx.fromBufferMulti(txsC, count);
  }
  calloc.free(countOutP);
  calloc.free(afterC);
  calloc.free(txsC);
  calloc.free(addrC);
  return txs;
}

IntResult transactionFeeFromIsolate(int _dummy) {
  // as we are running this in an isolate we need to reinit a LibZap instance
  // to get the function pointer as closures can not be passed to isolates
  var libzap = LibZap();

  var feeP = calloc<Int64>();
  var res = libzap.lzapTransactionFee(feeP) != 0;
  int fee = feeP.value;
  calloc.free(feeP);
  return IntResult(res, fee);
}

Tx transactionBroadcastFromIsolate(SpendTx spendTx) {
  // as we are running this in an isolate we need to reinit a LibZap instance
  // to get the function pointer as closures can not be passed to isolates
  var libzap = LibZap();

  var spendTxC = spendTx.toBuffer();
  var txC = Tx.allocateMem();
  var result = libzap.lzapTransactionBroadcast(spendTxC, txC);
  Tx tx;
  if (result != 0)
    tx = Tx.fromBuffer(txC);
  calloc.free(txC);
  calloc.free(spendTxC);
  return tx;
}

//
// LibZap class
//

class LibZap {

  LibZap() {
    libzap = dlopenPlatformSpecific("zap");
    lzapVersion = libzap
        .lookup<NativeFunction<lzap_version_native_t>>("lzap_version")
        .asFunction();
    lzapNodeGet = libzap
        .lookup<NativeFunction<lzap_node_get_t>>("lzap_node_get")
        .asFunction();
    lzapNodeSet = libzap
        .lookup<NativeFunction<lzap_node_set_native_t>>("lzap_node_set")
        .asFunction();
    lzapNetworkGet = libzap
        .lookup<NativeFunction<lzap_network_get_native_t>>("lzap_network_get")
        .asFunction();
    lzapNetworkSet = libzap
        .lookup<NativeFunction<lzap_network_set_native_t>>("lzap_network_set")
        .asFunction();
    lzapAssetIdGet = libzap
        .lookup<NativeFunction<lzap_asset_id_get_t>>("lzap_asset_id_get")
        .asFunction();
    lzapAssetIdSet = libzap
        .lookup<NativeFunction<lzap_asset_id_set_native_t>>("lzap_asset_id_set")
        .asFunction();
    lzapMnemonicCreate = libzap
        .lookup<NativeFunction<lzap_mnemonic_create_native_t>>("lzap_mnemonic_create")
        .asFunction();
    lzapMnemonicCheck = libzap
        .lookup<NativeFunction<lzap_mnemonic_check_native_t>>("lzap_mnemonic_check")
        .asFunction();
    lzapMnemonicWordlist = libzap
        .lookup<NativeFunction<lzap_mnemonic_wordlist_t>>("lzap_mnemonic_wordlist")
        .asFunction();

    lzapSeedAddress = libzap
        .lookup<NativeFunction<lzap_seed_address_native_t>>("lzap_seed_address")
        .asFunction();
    lzapAddressCheck = libzap
        .lookup<NativeFunction<lzap_address_check_ns_native_t>>("lzap_address_check_ns")
        .asFunction();
    lzapAddressBalance = libzap
        .lookup<NativeFunction<lzap_address_balance_ns_native_t>>("lzap_address_balance_ns")
        .asFunction();
    lzapAddressTransactions = libzap
        .lookup<NativeFunction<lzap_address_transactions2_ns_native_t>>("lzap_address_transactions2_ns")
        .asFunction();
    lzapTransactionFee = libzap
        .lookup<NativeFunction<lzap_transaction_fee_ns_native_t>>("lzap_transaction_fee_ns")
        .asFunction();
    lzapTransactionCreate = libzap
        .lookup<NativeFunction<lzap_transaction_create_ns_native_t>>("lzap_transaction_create_ns")
        .asFunction();
    lzapTransactionBroadcast = libzap
        .lookup<NativeFunction<lzap_transaction_broadcast_ns_native_t>>("lzap_transaction_broadcast_ns")
        .asFunction();
    lzapMessageSign = libzap
        .lookup<NativeFunction<lzap_message_sign_ns_native_t>>("lzap_message_sign_ns")
        .asFunction();
  }

  static const String TESTNET_ASSET_ID = "CgUrFtinLXEbJwJVjwwcppk4Vpz1nMmR3H5cQaDcUcfe";
  static const String MAINNET_ASSET_ID = "9R3iLi4qGLVWKc16Tg98gmRvgg1usGEYd7SgC1W5D6HB";

  DynamicLibrary libzap;
  lzap_version_t lzapVersion;
  lzap_node_get_t lzapNodeGet;
  lzap_node_set_t lzapNodeSet;
  lzap_network_get_t lzapNetworkGet;
  lzap_network_set_t lzapNetworkSet;
  lzap_asset_id_get_t lzapAssetIdGet;
  lzap_asset_id_set_t lzapAssetIdSet;
  lzap_mnemonic_create_t lzapMnemonicCreate;
  lzap_mnemonic_check_t lzapMnemonicCheck;
  lzap_mnemonic_wordlist_t lzapMnemonicWordlist;
  lzap_seed_address_t lzapSeedAddress;
  lzap_address_check_ns_t lzapAddressCheck;
  lzap_address_balance_ns_t lzapAddressBalance;
  lzap_address_transactions2_ns_t lzapAddressTransactions;
  lzap_transaction_Fee_ns_t lzapTransactionFee;
  lzap_transaction_create_ns_t lzapTransactionCreate;
  lzap_transaction_broadcast_ns_t lzapTransactionBroadcast;
  lzap_message_sign_ns_t lzapMessageSign;

  static String paymentUri(bool testnet, String address, int amount, String deviceName) {
    var uri = "waves://$address?asset=${testnet ? TESTNET_ASSET_ID : MAINNET_ASSET_ID}";
    if (amount != null)
      uri += "&amount=$amount";
    if (deviceName != null && deviceName.isNotEmpty)
      uri += '&attachment={"device_name":"$deviceName"}';
    return uri;
  }

  static String paymentUriDec(bool testnet, String address, Decimal amount, String deviceName) {
    if (amount != null && amount > Decimal.fromInt(0)) {
      amount = amount * Decimal.fromInt(100);
      var amountInt = amount.toInt();
      return paymentUri(testnet, address, amountInt, deviceName);
    }
    return paymentUri(testnet, address, null, deviceName);
  }

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

  bool assetIdSet(String value) {
    var valueC = value.toNativeUtf8();
    var res = lzapAssetIdSet(valueC) != 0;
    calloc.free(valueC);
    return res;
  }

bool networkParamsSet(String assetIdMainnet, String assetIdTestnet, String nodeUrlMainnet, String nodeUrlTestnet, bool testnet) {
    var result = true;
    print('testnetSet($testnet)..');
    if (!testnetSet(testnet))
      result =  false;
    if (testnet && assetIdTestnet != null) {
      print('assetIdSet("$assetIdTestnet")..');
      if (!assetIdSet(assetIdTestnet))
        result =  false;
    } else if (!testnet && assetIdMainnet != null) {
      print('assetIdSet("$assetIdMainnet")..');
      if (!assetIdSet(assetIdMainnet))
        result =  false;
    } else {
      print('assetIdSet("")..');
      if (!assetIdSet(''))
        result =  false;
    }
    if (testnet && nodeUrlTestnet != null) {
      print('nodeSet("$nodeUrlTestnet")..');
      if (!nodeSet(nodeUrlTestnet))
        result =  false;
    } else if (!testnet && nodeUrlMainnet != null) {
      print('nodeSet("$nodeUrlMainnet")..');
      if (!nodeSet(nodeUrlMainnet))
        result =  false;
    } else {
      print('nodeSet("")..');
      if (!nodeSet(''))
        result =  false;
    }
    print('networkParamsSet = $result');
    return result;
  }

  String mnemonicCreate() {
    var mem = "0" * 1024;
    var outputC = mem.toNativeUtf8();
    var res = lzapMnemonicCreate(outputC, 1024);
    var mnemonic = outputC.toDartString();
    calloc.free(outputC);
    if (res != 0)
      return mnemonic;
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

  static Future<IntResult> addressBalance(String address) async {
    return compute(addressBalanceFromIsolate, address);
  }

  static Future<Iterable<Tx>> addressTransactions(String address, int count, String after) async {
    return compute(addressTransactionsFromIsolate, AddrTxsRequest(address, count, after));
  }

  static Future<IntResult> transactionFee() async {
    return compute(transactionFeeFromIsolate, null);
  }

  SpendTx transactionCreate(String seed, String recipient, int amount, int fee, String attachment) {
    var seedC = seed.toNativeUtf8();
    var recipientC = recipient.toNativeUtf8();
    if (attachment == null)
      attachment = "";
    var attachmentC = attachment.toNativeUtf8();
    var outputC = SpendTx.allocateMem();
    lzapTransactionCreate(seedC, recipientC, amount, fee, attachmentC, outputC);
    var spendTx = SpendTx.fromBuffer(outputC);
    calloc.free(outputC);
    calloc.free(attachmentC);
    calloc.free(recipientC);
    calloc.free(seedC);
    return spendTx;
  }

  static Future<Tx> transactionBroadcast(SpendTx spendTx) {
    return compute(transactionBroadcastFromIsolate, spendTx);
  }

  Signature messageSign(String seed, Iterable<int> message) {
    var seedC = seed.toNativeUtf8();
    var messageC = calloc<Uint8>(message.length);
    copyInto(messageC, 0, message);
    var outputC = Signature.allocateMem();
    lzapMessageSign(seedC, messageC, message.length, outputC);
    var signature = Signature.fromBuffer(outputC);
    calloc.free(outputC);
    calloc.free(messageC);
    calloc.free(seedC);
    return signature;
  }
}
