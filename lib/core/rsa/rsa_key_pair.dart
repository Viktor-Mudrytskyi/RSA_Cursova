class RSAKeyPair {
  final RSAPrivateKey privateKey;
  final RSAPublicKey publicKey;

  RSAKeyPair({
    required this.privateKey,
    required this.publicKey,
  });
}

class RSAPublicKey {
  final BigInt a;
  final BigInt n;

  RSAPublicKey({
    required this.a,
    required this.n,
  });

  @override
  String toString() {
    return '(A = $a, \nN = $n)';
  }
}

class RSAPrivateKey {
  final BigInt b;
  final BigInt q;
  final BigInt p;
  final BigInt n;

  RSAPrivateKey({
    required this.b,
    required this.q,
    required this.p,
    required this.n,
  });

  @override
  String toString() {
    return '(B = $b, N = $n, P = $p, Q = $q)';
  }
}
