// This function written in Swift is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import Foundation

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
func ciede2000(_ l1: Double, _ a1: Double, _ b1: Double, _ l2: Double, _ a2: Double, _ b2: Double, _ kl: Double = 1.0, _ kc: Double = 1.0, _ kh: Double = 1.0, _ canonical: Bool = false) -> Double {
	// Working in Swift with the CIEDE2000 color-difference formula.
	// kl, kc, kh are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	var c1 = b1 * b1, c2 = b2 * b2;
	var n = (sqrt(a1 * a1 + c1) + sqrt(a2 * a2 + c2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var c = a1 * n;
	c1 = sqrt(c * c + c1);
	var h1 = atan2(b1, c);
	if h1 < 0.0 { h1 += 2.0 * .pi; }
	c = a2 * n;
	c2 = sqrt(c * c + c2);
	var h2 = atan2(b2, c);
	if h2 < 0.0 { h2 += 2.0 * .pi; }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_mean = (h1 + h2) * 0.5, h_delta = (h2 - h1) * 0.5;
	// The part where most programmers get it wrong.
	if .pi + 1E-14 < abs(h2 - h1) {
		h_delta += .pi;
		if canonical && .pi + 1E-14 < h_mean {
			// Sharma’s implementation, OpenJDK, ...
			h_mean -= .pi;
		} else {
			// Lindbloom’s implementation, Netflix’s VMAF, ...
			h_mean += .pi;
		}
	}
	n = (c1 + c2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	var r_t = -2.0 * sqrt(n / (n + 6103515625.0));
	n = 36.0 * h_mean - 55.0 * .pi;
	r_t *= sin(.pi / 3.0 * exp(n * n / (-25.0 * .pi * .pi)));
	n = (l1 + l2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	let l = (l2 - l1) / (kl * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	let t = 1.0	- 0.17 * sin(h_mean + .pi / 3.0)
			+ 0.24 * sin(2.0 * h_mean + .pi * 0.5)
			+ 0.32 * sin(3.0 * h_mean + 8.0 * .pi / 15.0)
			- 0.20 * sin(4.0 * h_mean + 3.0 * .pi / 20.0);
	n = c1 + c2;
	// Hue.
	let h = 2.0 * sqrt(c1 * c2) * sin(h_delta) / (kh * (1.0 + 0.0075 * n * t));
	// Chroma.
	c = (c2 - c1) / (kc * (1.0 + 0.0225 * n));
	// The result reflects the actual geometric distance in color space, given a tolerance of 3.6e-13.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// If you remove the constant 1E-14, the code will continue to work, but CIEDE2000
// interoperability between all programming languages will no longer be guaranteed.

// Source code tested by Michel LEONARD
// Website: ciede2000.pages-perso.free.fr
