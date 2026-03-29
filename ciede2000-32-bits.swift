// This function written in Swift is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import Foundation

// The classic CIE ΔE2000 implementation, which operates on two L*a*b* colors, and returns their difference.
// "l" ranges from 0 to 100, while "a" and "b" are unbounded and commonly clamped to the range of -128 to 127.
func ciede2000(_ l1: Float, _ a1: Float, _ b1: Float, _ l2: Float, _ a2: Float, _ b2: Float, _ kl: Float = 1.0, _ kc: Float = 1.0, _ kh: Float = 1.0, _ canonical: Bool = false) -> Float {
	// Working in Swift with the CIEDE2000 color-difference formula.
	// kl, kc, kh are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	var c1 = b1 * b1, c2 = b2 * b2;
	var n = (sqrt(a1 * a1 + c1) + sqrt(a2 * a2 + c2)) * (0.5 as Float);
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = (1.0 as Float) + (0.5 as Float) * ((1.0 as Float) - sqrt(n / (n + (6103515625.0 as Float))));
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var c = a1 * n;
	c1 = sqrt(c * c + c1);
	var h1 = atan2(b1, c);
	if h1 < (0.0 as Float) { h1 += (2.0 as Float) * .pi; }
	c = a2 * n;
	c2 = sqrt(c * c + c2);
	var h2 = atan2(b2, c);
	if h2 < (0.0 as Float) { h2 += (2.0 as Float) * .pi; }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_mean = (h1 + h2) * (0.5 as Float), h_delta = (h2 - h1) * (0.5 as Float);
	// The part where most programmers get it wrong.
	if .pi + (1E-6 as Float) < abs(h2 - h1) {
		h_delta += .pi;
		if canonical && .pi + (1E-6 as Float) < h_mean {
			// Sharma’s implementation, OpenJDK, ...
			h_mean -= .pi;
		} else {
			// Lindbloom’s implementation, Netflix’s VMAF, ...
			h_mean += .pi;
		}
	}
	n = (c1 + c2) * (0.5 as Float);
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	var r_t = (-2.0 as Float) * sqrt(n / (n + (6103515625.0 as Float)));
	n = (36.0 as Float) * h_mean - (55.0 as Float) * .pi;
	r_t *= sin(.pi / (3.0 as Float) * exp(n * n / ((-25.0 as Float) * .pi * .pi)));
	n = (l1 + l2) * (0.5 as Float);
	n = (n - (50.0 as Float)) * (n - (50.0 as Float));
	// Lightness.
	let l = (l2 - l1) / (kl * ((1.0 as Float) + (0.015 as Float) * n / sqrt((20.0 as Float) + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	let t = (1.0 as Float)	- (0.17 as Float) * sin(h_mean + .pi / (3.0 as Float))
			+ (0.24 as Float) * sin((2.0 as Float) * h_mean + .pi * (0.5 as Float))
			+ (0.32 as Float) * sin((3.0 as Float) * h_mean + (8.0 as Float) * .pi / (15.0 as Float))
			- (0.20 as Float) * sin((4.0 as Float) * h_mean + (3.0 as Float) * .pi / (20.0 as Float));
	n = c1 + c2;
	// Hue.
	let h = (2.0 as Float) * sqrt(c1 * c2) * sin(h_delta) / (kh * ((1.0 as Float) + (0.0075 as Float) * n * t));
	// Chroma.
	c = (c2 - c1) / (kc * ((1.0 as Float) + (0.0225 as Float) * n));
	// The result reflects the actual geometric distance in color space, given a tolerance of 2.1e-4.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// If you remove the constant 1E-6, the code will continue to work, but CIEDE2000
// interoperability between all programming languages will no longer be guaranteed.

// Source code tested by Michel LEONARD
// Website: ciede2000.pages-perso.free.fr
