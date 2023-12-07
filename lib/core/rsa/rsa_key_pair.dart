class RSAKeyPair {
  BigInt n; // modulus
  BigInt e; // public exponent
  BigInt d; // private exponent

  RSAKeyPair(this.n, this.e, this.d);
}
