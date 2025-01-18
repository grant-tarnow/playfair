# playfair

A simple [playfair cipher](https://en.wikipedia.org/wiki/Playfair_cipher) tool in perl.

## Usage

Takes 3 arguments:

1. An operation, either `enc` (encipher) or `dec` (decipher).
2. A keyword. It must be a single word with no repeat letters.
3. A text (plaintext or ciphertext) to operate on. No spaces or punctuation.

## Notes

- Due to how the playfair cipher works, this tool will convert any letter `j`s to `i`s.
- It will automatically insert `x`s where needed to encode letter pairs, so no need to do that yourself.
- Just know that it doesn't know how to strip those `x`s back out when deciphering.
- It's pretty simple and not the most user friendly. I mostly built this to see if I could figure out how to code the cipher logic.
