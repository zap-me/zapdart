import 'package:decimal/decimal.dart';

import 'libzap_stub.dart' if (dart.library.io) 'libzap_impl.dart';

class IntResult {
  bool success;
  int value;
  IntResult(this.success, this.value);
}

class Tx {
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
  bool success;
  Iterable<int> data;
  Iterable<int> signature;

  SpendTx(this.success, this.data, this.signature);
}

class Signature {
  bool success;
  Iterable<int> signature;

  Signature(this.success, this.signature);
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

abstract class LibZap {
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

  factory LibZap() => getLibZap();

  int version();

  String nodeGet();

  bool nodeSet(String url);

  bool testnetGet();

  bool testnetSet(bool value);

  String assetIdGet();

  void assetIdSet(String value);

  bool networkParamsSet(String? assetIdMainnet, String? assetIdTestnet, String? nodeUrlMainnet, String? nodeUrlTestnet, bool testnet);

  String? mnemonicCreate();

  bool mnemonicCheck(String mnemonic);

  List<String> mnemonicWordlist();

  String seedAddress(String seed);

  bool addressCheck(String address);

  Future<IntResult> addressBalance(String address);

  Future<AddrTxsResult> addressTransactions(String address, int count, String? after);

  Future<IntResult> transactionFee();

  SpendTx transactionCreate(String seed, String recipient, int amount, int fee, String? attachment);

  Future<Tx?> transactionBroadcast(SpendTx spendTx);

  Signature messageSign(String seed, Iterable<int> message);
}
