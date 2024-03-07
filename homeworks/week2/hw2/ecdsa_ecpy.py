import os
import secrets
from ecpy.curves import Curve, Point
from dotenv import load_dotenv
from Crypto.Hash import keccak
from pydantic import BaseModel


class Signature(BaseModel):
    r: int
    s: int


load_dotenv()

N = 115792089237316195423570985008687907852837564279074904382605163141518161494337


def generate_pub_key(private_key: int, G: Point) -> Point:
    """Generates public key given a private and a generator point."""
    return private_key * G


def get_generator_point() -> Point:
    """Constructs and returns G."""

    # Specific elliptic curve
    curve = Curve.get_curve("secp256k1")

    # Construct G
    x_value = (
        55066263022277343669578718895168534326250603453777594175500187360389116729240
    )
    y_value = (
        32670510020758816978083085130507043184471273380659243275938904335757337482424
    )
    return Point(x_value, y_value, curve)


def get_hashed_message(message: str) -> int:
    """Computes and returns hashed message."""
    byte_string = message.encode("utf-8")
    k = keccak.new(digest_bits=256)
    k.update(byte_string)
    return int(k.hexdigest(), 16)


def get_random_k() -> int:
    """Generates and returns a random k value that will only be used once."""
    return secrets.randbelow(N)


def sign_message(h: int, G: Point, pk: int) -> Signature:
    """Signs a hashed message."""

    # Get random k
    k = get_random_k()

    # Extract x value of the point, k * G
    r = (k * G).x

    # Get k inverse
    k_inverse = pow(k, -1, N)

    # Calculate s
    s_numerator = k_inverse * (h + r * pk)
    s = pow(s_numerator, 1, N)

    return Signature(r=r, s=s)


def verify_signature(pub_key: int, G: Point, sig: Signature, h: int) -> bool:
    """Verifies a provided signature is valid, given the signature, a hashed message, and a signatory public key."""

    # Get s inverse
    s_inverse = pow(sig.s, -1, N)

    # Get r prime
    r_prime_point = s_inverse * (h * G + sig.r * pub_key)
    r_prime = r_prime_point.x

    # Evaluate equality
    return r_prime == sig.r


if __name__ == "__main__":
    # Get generator point
    G = get_generator_point()

    # Generate public key
    pk = int(os.getenv("PRIVATE_KEY"))
    pub_key = generate_pub_key(private_key=pk, G=G)

    # Message to sign
    message = "Alice sends 10 tokens to Bob."
    h = get_hashed_message(message=message)

    # Sign message
    sig = sign_message(h=h, G=G, pk=pk)

    # Verify signature
    is_valid = verify_signature(pub_key=pub_key, G=G, sig=sig, h=h)
    print(is_valid)
