class User {
  User({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.token,
  });
  late final String name;
  late final String email;
  late final String password;
  late final String phone;
  late final String token;

  User.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];

    if (json.containsKey('password')) {
      password = json['password'];
    }

    if (json.containsKey('phone')) {
      phone = json['phone'];
    }

    if (json.containsKey('token')) {
      token = json['token'];
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['name'] = name;
    _data['email'] = email;
    _data['password'] = password;
    _data['phone'] = phone;
    _data['token'] = token;
    return _data;
  }
}

class Extract {
  late final Balance balance;
  late final Addresses addresses;

  Extract({required this.balance, required this.addresses});

  Extract.fromJson(Map<String, dynamic> json) {
    balance = (json['balance'] != null ? Balance.fromJson(json['balance']) : null)!;
    addresses = (json['addresses'] != null ? Addresses.fromJson(json['addresses']) : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (balance != null) {
      data['balance'] = balance.toJson();
      data['addresses'] = addresses.toJson();
    }
    return data;
  }
}

class Balance {
  late final Currency BTC;
  late final Currency ETH;
  late final Currency LTC;
  late final String Total;

  Balance({required this.BTC, required this.ETH, required this.LTC, required this.Total});

  Balance.fromJson(Map<String, dynamic> json) {
    BTC = (json['BTC'] != null ? Currency.fromJson(json['BTC']) : null)!;
    ETH = (json['ETH'] != null ? Currency.fromJson(json['ETH']) : null)!;
    LTC = (json['LTC'] != null ? Currency.fromJson(json['LTC']) : null)!;
    Total = json['Total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['BTC'] = BTC.toJson();
    data['ETH'] = ETH.toJson();
    data['LTC'] = LTC.toJson();
    data['Total'] = Total;
    return data;
  }
}

class Currency {
  late final double value;
  late final double converted;

  Currency({required this.value, required this.converted});

  Currency.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    converted = json['converted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['value'] = value;
    data['converted'] = converted;
    return data;
  }
}

class Addresses {
  late final Wallet BTCAddress;
  late final Wallet ETHAddress;
  late final Wallet LTCAddress;

  Addresses({required this.BTCAddress, required this.ETHAddress, required this.LTCAddress});

  Addresses.fromJson(Map<String, dynamic> json) {
    BTCAddress = (json['BTC'] != null ? Wallet.fromJson(json['BTC']) : null)!;
    ETHAddress = (json['ETH'] != null ? Wallet.fromJson(json['ETH']) : null)!;
    LTCAddress = (json['LTC'] != null ? Wallet.fromJson(json['LTC']) : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['BTC'] = BTCAddress.toJson();
    data['ETH'] = ETHAddress.toJson();
    data['LTC'] = LTCAddress.toJson();
    return data;
  }
}

class Wallet {
  late final String value;
  Wallet({required this.value});

  Wallet.fromJson(Map<String, dynamic> json) {
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['value'] = value;
    return data;
  }
}

class Transactions {
  Transactions({
    required this.extract,
  });
  late final List<Transaction> extract;

  Transactions.fromJson(Map<String, dynamic> json) {
    extract = List.from(json['extract']).map((e) => Transaction.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['items'] = extract.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Transaction {
  Transaction({required this.currency, required this.fromAddress, required this.toAddress, required this.value, required this.hash, required this.date, required this.message, required this.fee});
  late final String currency;
  late final String fromAddress;
  late final String toAddress;
  late final double value;
  late final String hash;
  late final String date;
  late final String message;
  late final double fee;

  Transaction.fromJson(Map<String, dynamic> json) {
    hash = json['hash'];
    date = json['date'];

    if (json.containsKey('currency')) {
      currency = json['currency'];
    }
    if (json.containsKey('fromAddress')) {
      fromAddress = json['fromAddress'];
    }
    if (json.containsKey('toAddress')) {
      toAddress = json['toAddress'];
    }
    if (json.containsKey('value')) {
      value = json['value'];
    }
    if (json.containsKey('message')) {
      message = json['message'];
    }
    if (json.containsKey('fee')) {
      fee = json['fee'];
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['hash'] = hash;
    _data['date'] = date;
    _data['fee'] = fee;
    return _data;
  }
}

class Error {
  Error({required this.detail});
  late final ErrorDetail detail;

  Error.fromJson(Map<String, dynamic> json) {
    detail = (json['detail'] != null ? ErrorDetail.fromJson(json['detail']) : null)!;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['detail'] = detail;
    return _data;
  }
}

class ErrorDetail {
  ErrorDetail({required this.msg});
  late final String msg;
  ErrorDetail.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('msg')) {
      msg = json['msg'];
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['msg'] = msg;
    return _data;
  }
}
