import "dart:convert";
import 'package:flutter/foundation.dart';
import 'package:decimal/decimal.dart';

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
  String? attachment;
  int amount;
  int fee;
  int timestamp;

  Tx(this.type, this.id, this.sender, this.recipient, this.assetId, this.feeAsset, this.attachment, this.amount, this.fee, this.timestamp);
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
}

class Signature {
  static final int32FieldSize = 4;
  static final sigFieldSize = 64;
  static final totalSize = int32FieldSize + sigFieldSize;
  
  bool success;
  Iterable<int> signature;

  Signature(this.success, this.signature);

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

class AddrTxsRequest {
  String address;
  int count;
  String? after;
  AddrTxsRequest(this.address, this.count, this.after);
}
class AddrTxsResult {
  bool success;
  Iterable<Tx> txs;
  AddrTxsResult(this.success, this.txs);
}

//
// LibZap class
//

class LibZap {

  LibZap() {
    
  }

  static const String TESTNET_ASSET_ID = "CgUrFtinLXEbJwJVjwwcppk4Vpz1nMmR3H5cQaDcUcfe";
  static const String MAINNET_ASSET_ID = "9R3iLi4qGLVWKc16Tg98gmRvgg1usGEYd7SgC1W5D6HB";

  static String paymentUri(bool testnet, String address, int? amount, String? deviceName) {
    var uri = "waves://$address?asset=${testnet ? TESTNET_ASSET_ID : MAINNET_ASSET_ID}";
    if (amount != null)
      uri += "&amount=$amount";
    if (deviceName != null && deviceName.isNotEmpty)
      uri += '&attachment={"device_name":"$deviceName"}';
    return uri;
  }

  static String paymentUriDec(bool testnet, String address, Decimal? amount, String? deviceName) {
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
    return 0;
  }

  String nodeGet() {
    return '';
  }

  bool nodeSet(String url) {
    return true;
  }

  bool testnetGet() {
    return false;
  }

  bool testnetSet(bool value) {
    return true;
  }

  String assetIdGet() {
    return '';
  }

  void assetIdSet(String value) {
  }

bool networkParamsSet(String? assetIdMainnet, String? assetIdTestnet, String? nodeUrlMainnet, String? nodeUrlTestnet, bool testnet) {
    return true;
  }

  String? mnemonicCreate() {
    
    return null;
  }

  bool mnemonicCheck(String mnemonic) {
    return true;
  }

  List<String> mnemonicWordlist() {
    var wordlist = <String>[];
    return wordlist;
  }

  String seedAddress(String seed) {
    return 'address';
  }

  bool addressCheck(String address) {
    return true;
  }

  static Future<IntResult> addressBalance(String address) async {
    return IntResult(true, 1);
  }

  static Future<AddrTxsResult> addressTransactions(String address, int count, String? after) async {
    return AddrTxsResult(true, []);
  }

  static Future<IntResult> transactionFee() async {
    return IntResult(true, 1);
  }

  SpendTx transactionCreate(String seed, String recipient, int amount, int fee, String? attachment) {
    return SpendTx(true, [], []);
  }

  static Future<Tx?> transactionBroadcast(SpendTx spendTx) async {
    return Tx(0, '', '', '', '', '', '', 0, 0, 0);
  }

  Signature messageSign(String seed, Iterable<int> message) {
    return Signature(true, []);
  }
}
