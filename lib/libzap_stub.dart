import 'libzap.dart';

LibZap getLibZap() => LibZapStub();

//
// LibZap class
//

class LibZapStub implements LibZap {

  //
  // stubbed libzap wrapper functions
  //

  int version() { 
    return -1;
  }

  String nodeGet() {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  bool nodeSet(String url) {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  bool testnetGet() {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  bool testnetSet(bool value) {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  String assetIdGet() {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  void assetIdSet(String value) {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  bool networkParamsSet(String? assetIdMainnet, String? assetIdTestnet, String? nodeUrlMainnet, String? nodeUrlTestnet, bool testnet) {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  String? mnemonicCreate() {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  bool mnemonicCheck(String mnemonic) {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  List<String> mnemonicWordlist() {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  String seedAddress(String seed) {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  bool addressCheck(String address) {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  Future<IntResult> addressBalance(String address) async {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  Future<AddrTxsResult> addressTransactions(String address, int count, String? after) async {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  Future<IntResult> transactionFee() async {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  SpendTx transactionCreate(String seed, String recipient, int amount, int fee, String? attachment) {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  Future<Tx?> transactionBroadcast(SpendTx spendTx) {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }

  Signature messageSign(String seed, Iterable<int> message) {
    throw UnsupportedError('Cannot use LibZap on this platform!');
  }
}
